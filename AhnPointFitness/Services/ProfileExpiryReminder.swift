import Foundation
import UserNotifications

/// Reminds you to reinstall before the development build stops launching.
///
/// A free Apple Developer profile lasts seven days; when it lapses the app
/// simply refuses to open, with no warning. The signed profile is embedded in
/// the bundle, so the app can read its own expiry and schedule a local
/// notification for the evening before. Every reinstall embeds a fresh
/// profile, so every launch re-derives the date and replaces the reminder.
///
/// Simulator builds carry no profile and paid-team profiles last a year, so
/// in both cases this is a harmless no-op or a reminder a long way off.
enum ProfileExpiryReminder {

    static let notificationID = "profile.expiry.reminder"
    /// Reminder fires at this hour, local time, the day before expiry.
    static let reminderHour = 20

    static func scheduleIfNeeded(bundle: Bundle = .main, now: Date = Date()) {
        guard let url = bundle.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              let expiry = expirationDate(fromProfileData: data),
              let fireAt = reminderDate(for: expiry, now: now)
        else { return }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "AHN POINT expires tomorrow"
            content.body = "The dev build stops launching \(Self.expiryText(expiry)). "
                + "Plug the phone in and reinstall tonight."
            content.sound = .default

            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: fireAt)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(
                identifier: notificationID, content: content, trigger: trigger))
        }
    }

    /// The profile is a CMS-signed envelope around an XML plist. Rather than
    /// verify the signature — Security.framework's CMS API is not available
    /// on iOS — locate the plist bytes inside it and read `ExpirationDate`.
    static func expirationDate(fromProfileData data: Data) -> Date? {
        guard let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex)
        else { return nil }
        let plist = data[start.lowerBound..<end.upperBound]
        let object = try? PropertyListSerialization.propertyList(from: plist, format: nil)
        return (object as? [String: Any])?["ExpirationDate"] as? Date
    }

    /// 8 PM local on the day before expiry, or nil when that moment has
    /// already passed — a stale reminder on launch day is worse than none.
    static func reminderDate(for expiry: Date, now: Date, calendar: Calendar = .current) -> Date? {
        guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: expiry)),
              let fireAt = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: dayBefore),
              fireAt > now
        else { return nil }
        return fireAt
    }

    private static func expiryText(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE 'at' h:mm a"
        return f.string(from: date)
    }
}
