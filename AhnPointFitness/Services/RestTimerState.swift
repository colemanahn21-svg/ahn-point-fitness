import Foundation
import Combine
import UserNotifications

/// App-wide rest timer. Countdown derives from an absolute `endDate`, so it
/// stays correct if the app backgrounds; a local notification fires at zero
/// even when the phone is locked.
@MainActor
final class RestTimerState: ObservableObject {
    @Published private(set) var endDate: Date?
    @Published private(set) var remaining: Int = 0

    private var ticker: AnyCancellable?
    private static let notificationID = "rest.timer.done"

    var isRunning: Bool { endDate != nil }

    func start(seconds: Int) {
        cancel()
        let end = Date().addingTimeInterval(TimeInterval(seconds))
        endDate = end
        remaining = seconds

        ticker = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }

        scheduleNotification(after: seconds)
    }

    func cancel() {
        ticker?.cancel()
        ticker = nil
        endDate = nil
        remaining = 0
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
    }

    var display: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func tick() {
        guard let end = endDate else { return }
        let left = Int(end.timeIntervalSinceNow.rounded(.up))
        if left <= 0 {
            // Timer done — the notification handles the alert; just clear UI.
            ticker?.cancel()
            ticker = nil
            endDate = nil
            remaining = 0
        } else {
            remaining = left
        }
    }

    private func scheduleNotification(after seconds: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Rest over"
            content.body = "Next set."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(seconds), repeats: false)
            let request = UNNotificationRequest(
                identifier: Self.notificationID, content: content, trigger: trigger)
            center.add(request)
        }
    }
}
