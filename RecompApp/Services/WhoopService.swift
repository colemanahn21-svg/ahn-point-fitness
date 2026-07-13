import Foundation

// MARK: - Errors

enum WhoopServiceError: LocalizedError {
    case notConnected
    case http(status: Int, body: String)
    case decoding(Error)
    case transport(Error)
    case retriesExhausted

    var errorDescription: String? {
        switch self {
        case .notConnected:           return "WHOOP not connected."
        case .http(let s, let b):     return "WHOOP API error (HTTP \(s)): \(b)"
        case .decoding(let e):        return "WHOOP API decode error: \(e.localizedDescription)"
        case .transport(let e):       return "WHOOP API network error: \(e.localizedDescription)"
        case .retriesExhausted:       return "WHOOP API failed after multiple retries."
        }
    }
}

// MARK: - WhoopService

@MainActor
final class WhoopService {

    private let auth: WhoopAuth
    private let session: URLSession
    private let decoder: JSONDecoder

    init(auth: WhoopAuth, session: URLSession = .shared) {
        self.auth = auth
        self.session = session
        let d = JSONDecoder()
        // WHOOP returns ISO-8601 timestamps as strings; we keep them as String
        // in the model layer and convert at the view boundary if needed.
        d.keyDecodingStrategy = .useDefaultKeys
        self.decoder = d
    }

    // MARK: - Public endpoints

    func getRecovery(start: Date, end: Date, limit: Int = 25) async throws -> [RecoveryRecord] {
        try await fetchPaged(
            path: "/recovery",
            query: dateRangeQuery(start: start, end: end, limit: limit)
        )
    }

    func getCycle(start: Date, end: Date, limit: Int = 25) async throws -> [CycleRecord] {
        try await fetchPaged(
            path: "/cycle",
            query: dateRangeQuery(start: start, end: end, limit: limit)
        )
    }

    func getSleep(start: Date, end: Date, limit: Int = 25) async throws -> [SleepRecord] {
        try await fetchPaged(
            path: "/activity/sleep",
            query: dateRangeQuery(start: start, end: end, limit: limit)
        )
    }

    func getWorkouts(start: Date, end: Date, limit: Int = 25) async throws -> [WorkoutRecord] {
        try await fetchPaged(
            path: "/activity/workout",
            query: dateRangeQuery(start: start, end: end, limit: limit)
        )
    }

    func getProfile() async throws -> ProfileRecord {
        try await performGET(path: "/user/profile/basic", query: [])
    }

    // MARK: - Pagination

    private func fetchPaged<T: Decodable>(
        path: String,
        query: [URLQueryItem],
        maxRecords: Int = 200
    ) async throws -> [T] {
        var collected: [T] = []
        var nextToken: String? = nil

        repeat {
            var q = query
            if let token = nextToken {
                q.append(URLQueryItem(name: "nextToken", value: token))
            }
            let page: WhoopCollection<T> = try await performGET(path: path, query: q)
            collected.append(contentsOf: page.records)
            nextToken = page.next_token
        } while nextToken != nil && collected.count < maxRecords

        return collected
    }

    // MARK: - HTTP

    private func performGET<T: Decodable>(
        path: String,
        query: [URLQueryItem]
    ) async throws -> T {
        guard let url = buildURL(path: path, query: query) else {
            throw WhoopServiceError.http(status: 0, body: "invalid URL for path \(path)")
        }
        return try await sendWithRetry(url: url, allowRefresh: true, attempt: 0)
    }

    private func sendWithRetry<T: Decodable>(
        url: URL,
        allowRefresh: Bool,
        attempt: Int
    ) async throws -> T {
        let token: String
        do {
            token = try await auth.getValidAccessToken()
        } catch is WhoopAuthError {
            throw WhoopServiceError.notConnected
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            // Network failure — exponential backoff (max 3 attempts)
            if attempt < 2 {
                let delay = UInt64(pow(2.0, Double(attempt)) * 0.5 * 1_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
                return try await sendWithRetry(url: url, allowRefresh: allowRefresh, attempt: attempt + 1)
            }
            throw WhoopServiceError.transport(error)
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        // 401 → force a refresh + retry once
        if status == 401 && allowRefresh {
            do {
                _ = try await auth.forceRefresh()
                return try await sendWithRetry(url: url, allowRefresh: false, attempt: 0)
            } catch {
                // forceRefresh wipes Keychain on failure → surface as not-connected
                throw WhoopServiceError.notConnected
            }
        }

        // 5xx → exponential backoff (max 3 attempts)
        if (500..<600).contains(status) && attempt < 2 {
            let delay = UInt64(pow(2.0, Double(attempt)) * 0.5 * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delay)
            return try await sendWithRetry(url: url, allowRefresh: allowRefresh, attempt: attempt + 1)
        }

        guard (200..<300).contains(status) else {
            let body = String(data: data, encoding: .utf8) ?? "<binary>"
            print("⚠️ WHOOP \(url.path) \(status):\n\(body)")
            throw WhoopServiceError.http(status: status, body: body)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            let body = String(data: data, encoding: .utf8) ?? "<binary>"
            print("⚠️ WHOOP \(url.path) decode error: \(error)\nBody:\n\(body)")
            throw WhoopServiceError.decoding(error)
        }
    }

    // MARK: - Helpers

    private func buildURL(path: String, query: [URLQueryItem]) -> URL? {
        var comps = URLComponents(string: WhoopConfig.apiBaseURL + path)
        comps?.queryItems = query.isEmpty ? nil : query
        return comps?.url
    }

    private func dateRangeQuery(start: Date, end: Date, limit: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "start",  value: Self.iso8601.string(from: start)),
            URLQueryItem(name: "end",    value: Self.iso8601.string(from: end)),
            URLQueryItem(name: "limit",  value: String(min(max(limit, 1), 25))),
        ]
    }

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
