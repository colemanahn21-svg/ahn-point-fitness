import Foundation
import SwiftData
@testable import AhnPointFitness

/// Shared helpers for building in-memory SwiftData fixtures.
enum TestSupport {
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([WorkoutLog.self, SetEntry.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Builds a WorkoutLog with sets described as (exercise, setNumber, weight, reps).
    @MainActor
    static func makeLog(
        in ctx: ModelContext,
        date: Date,
        day: String = "mon",
        sets: [(String, Int, Double?, Int?)]
    ) -> WorkoutLog {
        let log = WorkoutLog(date: date, day: day)
        ctx.insert(log)
        for (name, num, w, r) in sets {
            let entry = SetEntry(exerciseName: name, setNumber: num, weight: w, reps: r, log: log)
            ctx.insert(entry)
            log.sets.append(entry)
        }
        return log
    }

    /// A date at noon ET on the given y/m/d — stable regardless of test machine timezone.
    static func etDate(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        return cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
