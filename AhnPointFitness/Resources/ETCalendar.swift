import Foundation

/// The app's one calendar: America/New_York, Monday-start weeks. Every
/// user-facing date and every day or week window goes through this.
/// "Weekly" means the calendar week (Monday 00:00 ET onward), not the last
/// 7 days.
enum ET {
    static let timeZone = TimeZone(identifier: "America/New_York")!

    /// Gregorian, Eastern time, `firstWeekday = 2` (Monday).
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        cal.firstWeekday = 2
        return cal
    }()

    /// 00:00 ET on the ET day containing `date`.
    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Monday 00:00 ET of the calendar week containing `date`.
    static func weekStart(_ date: Date) -> Date? {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start
    }

    /// Whether two moments fall on the same ET calendar day.
    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }
}

/// Formats a weight for display: whole numbers drop the trailing ".0".
func formatWeight(_ w: Double) -> String {
    if w.truncatingRemainder(dividingBy: 1) == 0 {
        return String(Int(w))
    } else {
        return String(w)
    }
}
