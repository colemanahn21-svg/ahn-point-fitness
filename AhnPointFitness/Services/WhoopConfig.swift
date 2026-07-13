import Foundation

// Credentials live in WhoopSecrets.swift (gitignored).
// See WhoopSecrets.swift.example at the repo root.

enum WhoopConfig {
    static let clientID     = WhoopSecrets.clientID
    static let clientSecret = WhoopSecrets.clientSecret

    static let redirectURI     = "twoadays://oauth/callback"
    static let callbackScheme  = "twoadays"

    static let scopes: [String] = [
        "offline",            // ← required for WHOOP to issue a refresh token
        "read:recovery",
        "read:cycles",
        "read:sleep",
        "read:workout",
        "read:profile",
        "read:body_measurement"
    ]

    static let authorizationEndpoint = "https://api.prod.whoop.com/oauth/oauth2/auth"
    static let tokenEndpoint         = "https://api.prod.whoop.com/oauth/oauth2/token"
    static let apiBaseURL            = "https://api.prod.whoop.com/developer/v2"

    // Refresh access token if it expires within this window.
    static let refreshLeadTime: TimeInterval = 5 * 60
}
