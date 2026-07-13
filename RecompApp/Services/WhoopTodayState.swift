import Foundation
import SwiftUI

/// Shared state for the WHOOP "Today" data.
/// - WhoopTodayCard observes it to render tiles + footer.
/// - TodayView observes it to pick the dynamic Recovery Rule based on the
///   current `recoveryScore`.
/// Refresh logic and the cache load happen here so both consumers share a
/// single source of truth.
@MainActor
final class WhoopTodayState: ObservableObject {
    @Published var snapshot: WhoopTodaySnapshot?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init() {
        snapshot = WhoopTodayCache.load()
    }

    func refresh(auth: WhoopAuth) async {
        guard auth.isConnected, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let service = WhoopService(auth: auth)
        let now = Date()
        let thirtyDaysAgo = now.addingTimeInterval(-30 * 86_400)

        do {
            async let recoveries = service.getRecovery(start: thirtyDaysAgo, end: now)
            async let cycles     = service.getCycle(start: thirtyDaysAgo, end: now)
            async let sleeps     = service.getSleep(start: thirtyDaysAgo, end: now)

            let r = try await recoveries
            let c = try await cycles
            let s = try await sleeps

            let snap = WhoopTodaySnapshot.compute(recoveries: r, cycles: c, sleeps: s)
            snapshot = snap
            WhoopTodayCache.save(snap)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
