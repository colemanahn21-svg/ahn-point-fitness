import Foundation

/// Pure aggregation helpers for the Trends view. ET calendar weeks
/// (Monday-anchored), matching the rest of the app.
enum TrendsModel {
    struct WeekPoint: Identifiable, Equatable {
        let weekStart: Date
        let tonnage: Double   // Σ weight × reps across all sets that week

        var id: Date { weekStart }
    }

    private static var etCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        cal.firstWeekday = 2  // Monday
        return cal
    }

    /// Weekly training tonnage from workout logs, sorted by week ascending.
    /// Sets missing weight or reps contribute nothing.
    static func weeklyTonnage(logs: [WorkoutLog]) -> [WeekPoint] {
        let cal = etCalendar
        var byWeek: [Date: Double] = [:]

        for log in logs {
            guard let weekStart = cal.dateInterval(of: .weekOfYear, for: log.date)?.start
            else { continue }
            for set in log.sets {
                guard let w = set.weight, let r = set.reps else { continue }
                byWeek[weekStart, default: 0] += w * Double(r)
            }
        }

        return byWeek
            .filter { $0.value > 0 }
            .map { WeekPoint(weekStart: $0.key, tonnage: $0.value) }
            .sorted { $0.weekStart < $1.weekStart }
    }
}
