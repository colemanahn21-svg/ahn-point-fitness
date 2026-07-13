import Foundation
import AuthenticationServices
import Security
import UIKit

// MARK: - Errors

enum WhoopAuthError: LocalizedError {
    case invalidConfig
    case stateMismatch
    case noAuthorizationCode
    case userCancelled
    case tokenExchangeFailed(httpStatus: Int, body: String)
    case refreshFailed(httpStatus: Int, body: String)
    case notConnected
    case keychainError(OSStatus)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidConfig:                  return "Invalid WHOOP configuration."
        case .stateMismatch:                  return "Authentication failed (state mismatch). Try again."
        case .noAuthorizationCode:            return "No authorization code returned from WHOOP."
        case .userCancelled:                  return nil   // silent
        case .tokenExchangeFailed(let s, let b): return "Token exchange failed (HTTP \(s)): \(b)"
        case .refreshFailed(let s, let b):    return "Token refresh failed (HTTP \(s)): \(b)"
        case .notConnected:                   return "WHOOP is not connected."
        case .keychainError(let s):           return "Keychain error \(s)."
        case .decodingError(let e):           return "Could not decode token response: \(e.localizedDescription)"
        }
    }
}

// MARK: - WhoopAuth

/// Single source of truth for WHOOP OAuth state.
/// - Owns Keychain reads/writes for access + refresh tokens.
/// - Performs the authorization-code flow via ASWebAuthenticationSession.
/// - Refreshes the access token transparently when within `refreshLeadTime` of expiry.
@MainActor
final class WhoopAuth: NSObject, ObservableObject {

    @Published private(set) var isConnected: Bool = false
    @Published var lastError: String?

    // Hold the active session strongly so it isn't deallocated mid-flow.
    private var activeSession: ASWebAuthenticationSession?
    // CSRF nonce — set when starting auth, validated when callback returns.
    private var pendingState: String?

    private let keychainService = "com.recompapp.whoop"
    private enum Key {
        static let accessToken  = "access_token"
        static let refreshToken = "refresh_token"
        static let expiresAt    = "expires_at"   // ISO8601
    }

    override init() {
        super.init()
        // Connected if we have an access token (refresh may or may not be present).
        isConnected = (loadFromKeychain(Key.accessToken) != nil)
    }

    // MARK: - Public surface

    /// Launch the OAuth flow. On success, tokens are stored in Keychain and
    /// `isConnected` becomes true.
    func connect() async throws {
        let state = UUID().uuidString
        pendingState = state

        guard let authURL = buildAuthorizationURL(state: state) else {
            throw WhoopAuthError.invalidConfig
        }

        let callbackURL: URL
        do {
            callbackURL = try await startWebAuthSession(authURL: authURL)
        } catch let e as WhoopAuthError {
            if case .userCancelled = e { return }     // silent return per spec
            throw e
        }

        guard let comps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else {
            throw WhoopAuthError.noAuthorizationCode
        }
        let items = comps.queryItems ?? []
        let returnedState = items.first(where: { $0.name == "state" })?.value
        guard returnedState == pendingState else {
            throw WhoopAuthError.stateMismatch
        }
        guard let code = items.first(where: { $0.name == "code" })?.value else {
            throw WhoopAuthError.noAuthorizationCode
        }

        let bundle = try await exchangeCodeForTokens(code: code)
        try persistTokens(bundle)
        pendingState = nil
        isConnected = true
    }

    /// Wipe all stored tokens.
    func disconnect() {
        deleteFromKeychain(Key.accessToken)
        deleteFromKeychain(Key.refreshToken)
        deleteFromKeychain(Key.expiresAt)
        isConnected = false
    }

    /// Returns a valid access token, refreshing if it expires within `refreshLeadTime`.
    /// Throws `.notConnected` if no refresh token is present.
    /// Throws `.refreshFailed` (and clears Keychain) if WHOOP rejects refresh.
    func getValidAccessToken() async throws -> String {
        guard let access = loadFromKeychain(Key.accessToken),
              let expiryString = loadFromKeychain(Key.expiresAt),
              let expiry = Self.iso8601.date(from: expiryString) else {
            throw WhoopAuthError.notConnected
        }

        if expiry.timeIntervalSinceNow > WhoopConfig.refreshLeadTime {
            return access
        }
        return try await refreshAccessToken()
    }

    /// Forces a refresh regardless of expiry. Used by WhoopService when a 401
    /// suggests the cached access token has been revoked server-side.
    @discardableResult
    func forceRefresh() async throws -> String {
        try await refreshAccessToken()
    }

    /// Warm-up call for app foregrounding: refresh the access token if it's
    /// near expiry, but swallow all errors. This is a best-effort background
    /// task — failures must not surface to the user or clear tokens.
    func refreshIfNeeded() async {
        guard isConnected else { return }
        _ = try? await getValidAccessToken()
    }

    // MARK: - OAuth steps

    private func buildAuthorizationURL(state: String) -> URL? {
        var comps = URLComponents(string: WhoopConfig.authorizationEndpoint)
        comps?.queryItems = [
            .init(name: "client_id",     value: WhoopConfig.clientID),
            .init(name: "redirect_uri",  value: WhoopConfig.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope",         value: WhoopConfig.scopes.joined(separator: " ")),
            .init(name: "state",         value: state),
        ]
        return comps?.url
    }

    private func startWebAuthSession(authURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: WhoopConfig.callbackScheme
            ) { callback, error in
                if let error = error as NSError? {
                    if error.domain == ASWebAuthenticationSessionError.errorDomain,
                       error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: WhoopAuthError.userCancelled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let callback else {
                    continuation.resume(throwing: WhoopAuthError.noAuthorizationCode)
                    return
                }
                continuation.resume(returning: callback)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.activeSession = session
            session.start()
        }
    }

    private struct TokenBundle {
        let accessToken: String
        let refreshToken: String?
        let expiresAt: Date
    }

    private func exchangeCodeForTokens(code: String) async throws -> TokenBundle {
        let body: [String: String] = [
            "grant_type":    "authorization_code",
            "code":          code,
            "client_id":     WhoopConfig.clientID,
            "client_secret": WhoopConfig.clientSecret,
            "redirect_uri":  WhoopConfig.redirectURI,
        ]
        return try await postTokenRequest(body: body, mappingFailure: WhoopAuthError.tokenExchangeFailed)
    }

    private func refreshAccessToken() async throws -> String {
        guard let refresh = loadFromKeychain(Key.refreshToken) else {
            throw WhoopAuthError.notConnected
        }
        let body: [String: String] = [
            "grant_type":    "refresh_token",
            "refresh_token": refresh,
            "client_id":     WhoopConfig.clientID,
            "client_secret": WhoopConfig.clientSecret,
            "scope":         WhoopConfig.scopes.joined(separator: " "),
        ]
        do {
            let bundle = try await postTokenRequest(body: body, mappingFailure: WhoopAuthError.refreshFailed)
            try persistTokens(bundle)
            return bundle.accessToken
        } catch let e as WhoopAuthError {
            // Only wipe Keychain when WHOOP definitively rejects the refresh token
            // (invalid_grant on 400/401). Transient failures — network, 5xx, decode —
            // must preserve tokens so the next attempt can recover.
            if case .refreshFailed(let status, let body) = e,
               (status == 400 || status == 401),
               body.lowercased().contains("invalid_grant") {
                disconnect()
            }
            throw e
        }
    }

    private func postTokenRequest(
        body: [String: String],
        mappingFailure: (Int, String) -> WhoopAuthError
    ) async throws -> TokenBundle {
        guard let url = URL(string: WhoopConfig.tokenEndpoint) else {
            throw WhoopAuthError.invalidConfig
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = Self.formURLEncoded(body).data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        let bodyText = String(data: data, encoding: .utf8) ?? "<binary>"
        guard (200..<300).contains(status) else {
            print("⚠️ WHOOP token endpoint failed: HTTP \(status)\n\(bodyText)")
            throw mappingFailure(status, bodyText)
        }
        let token: WhoopTokenResponse
        do {
            token = try JSONDecoder().decode(WhoopTokenResponse.self, from: data)
        } catch {
            print("⚠️ WHOOP token decode failed. Response body:\n\(bodyText)\nError: \(error)")
            throw WhoopAuthError.decodingError(error)
        }
        return TokenBundle(
            accessToken: token.access_token,
            refreshToken: token.refresh_token,
            expiresAt: Date().addingTimeInterval(TimeInterval(token.expires_in))
        )
    }

    // MARK: - Keychain

    private func persistTokens(_ b: TokenBundle) throws {
        try saveToKeychain(Key.accessToken, value: b.accessToken)
        if let refresh = b.refreshToken {
            try saveToKeychain(Key.refreshToken, value: refresh)
        }
        // If the response omits refresh_token, keep the existing one — WHOOP
        // sometimes returns no new refresh on the refresh path, and the
        // previous token is still valid.
        try saveToKeychain(Key.expiresAt, value: Self.iso8601.string(from: b.expiresAt))
    }

    @discardableResult
    private func saveToKeychain(_ account: String, value: String) throws -> OSStatus {
        let data = Data(value.utf8)
        let baseQuery: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrService as String:  keychainService,
            kSecAttrAccount as String:  account,
        ]

        // Try update first; fall back to add.
        let updateAttrs: [String: Any] = [
            kSecValueData as String:      data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, updateAttrs as CFDictionary)
        if updateStatus == errSecSuccess { return updateStatus }

        if updateStatus == errSecItemNotFound {
            var addQuery = baseQuery
            addQuery[kSecValueData as String]      = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw WhoopAuthError.keychainError(addStatus)
            }
            return addStatus
        }
        throw WhoopAuthError.keychainError(updateStatus)
    }

    private func loadFromKeychain(_ account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain(_ account: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Helpers

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static func formURLEncoded(_ params: [String: String]) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")     // RFC 3986 unreserved
        return params
            .map { (k, v) in
                let ek = k.addingPercentEncoding(withAllowedCharacters: allowed) ?? k
                let ev = v.addingPercentEncoding(withAllowedCharacters: allowed) ?? v
                return "\(ek)=\(ev)"
            }
            .joined(separator: "&")
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension WhoopAuth: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)
            ?? ASPresentationAnchor()
    }
}
