import Foundation

/// Pure model for the 8-week training cycle.
///
/// The start date is stored as epoch seconds in
/// `@AppStorage(CycleModel.storageKey)`; `0` means no cycle is set.
/// All date math runs in America/New_York with Monday weeks, matching the
/// rest of the app. `now` is injectable for tests.
struct CycleModel {
    enum Phase: Equatable {
        case unset
        case upcoming(daysUntil: Int)
        case active(week: Int)   // 1...weekCount
        case completed
    }

    static let storageKey = "cycle.startDate"
    static let weekCount = 8

    let startDateRaw: Double
    let now: Date

    init(startDateRaw: Double, now: Date = Date()) {
        self.startDateRaw = startDateRaw
        self.now = now
    }

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private static var etCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = etTZ
        cal.firstWeekday = 2  // Monday
        return cal
    }

    var startDate: Date? {
        startDateRaw > 0 ? Date(timeIntervalSince1970: startDateRaw) : nil
    }

    /// The Monday-anchored end label date: start + 8 weeks (56 days).
    /// Matches the original programme's "Mar 30 – May 25" convention, where
    /// May 25 is the Monday after week 8.
    var endDate: Date? {
        startDate.flatMap {
            Self.etCalendar.date(byAdding: .day, value: Self.weekCount * 7, to: $0)
        }
    }

    var phase: Phase {
        guard let start = startDate else { return .unset }
        let cal = Self.etCalendar
        let startDay = cal.startOfDay(for: start)
        let today = cal.startOfDay(for: now)
        let days = cal.dateComponents([.day], from: startDay, to: today).day ?? 0
        if days < 0 { return .upcoming(daysUntil: -days) }
        let week = days / 7 + 1
        if week > Self.weekCount { return .completed }
        return .active(week: week)
    }

    /// 1...8 while active, nil otherwise.
    var currentWeek: Int? {
        if case .active(let w) = phase { return w }
        return nil
    }

    var isDeloadWeek: Bool { currentWeek == 4 }
    var isTaperWeek: Bool { currentWeek == Self.weekCount }

    /// "Mar 30 – May 25, 2026" (both years shown when they differ).
    var rangeString: String? {
        guard let start = startDate, let end = endDate else { return nil }
        return Self.formatRange(start: start, end: end)
    }

    /// Six-week range from start: "Mar 30 – May 11, 2026".
    var sixWeekRangeString: String? {
        guard let start = startDate,
              let end = Self.etCalendar.date(byAdding: .day, value: 42, to: start)
        else { return nil }
        return Self.formatRange(start: start, end: end)
    }

    static func formatRange(start: Date, end: Date) -> String {
        let cal = etCalendar
        let sameYear = cal.component(.year, from: start) == cal.component(.year, from: end)

        let monthDay = DateFormatter()
        monthDay.timeZone = etTZ
        monthDay.dateFormat = "MMM d"

        let monthDayYear = DateFormatter()
        monthDayYear.timeZone = etTZ
        monthDayYear.dateFormat = "MMM d, yyyy"

        if sameYear {
            return "\(monthDay.string(from: start)) – \(monthDayYear.string(from: end))"
        }
        return "\(monthDayYear.string(from: start)) – \(monthDayYear.string(from: end))"
    }
}
