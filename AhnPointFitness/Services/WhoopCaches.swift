import Foundation

// MARK: - Snapshot cache (UserDefaults; tokens stay in Keychain)

enum WhoopTodayCache {
    private static let key = "whoop.today.snapshot.v1"

    static func load() -> WhoopTodaySnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WhoopTodaySnapshot.self, from: data)
    }

    static func save(_ s: WhoopTodaySnapshot) {
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Profile cache (so Settings can show email without refetching)

struct WhoopCachedProfile: Codable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let cachedAt: Date

    var displayName: String? {
        let parts = [firstName, lastName].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    var displayLine: String? {
        if let e = email, !e.isEmpty { return e }
        return displayName
    }
}

enum WhoopProfileCache {
    private static let key = "whoop.profile.v1"

    static func load() -> WhoopCachedProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WhoopCachedProfile.self, from: data)
    }

    static func save(_ p: ProfileRecord) {
        let cached = WhoopCachedProfile(
            email: p.email,
            firstName: p.first_name,
            lastName: p.last_name,
            cachedAt: Date()
        )
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
