import Foundation
import SwiftData

/// Seeds four trailing weeks of plausible workout logs (plus a fake WHOOP
/// snapshot when none is cached) so a fresh install — e.g. someone cloning
/// the repo without a WHOOP account — sees a populated app.
///
/// Everything the seeder creates is tracked in UserDefaults so `unseed`
/// removes exactly what was added and nothing else. Real data always wins:
/// days that already have a log are skipped, and a real WHOOP snapshot is
/// never overwritten.
@MainActor
enum DemoSeeder {
    private static let seededIDsKey = "demo.seededLogIDs"
    private static let wroteSnapshotKey = "demo.wroteWhoopSnapshot"

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private static var etCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = etTZ
        cal.firstWeekday = 2  // Monday
        return cal
    }

    static var isSeeded: Bool {
        !(UserDefaults.standard.stringArray(forKey: seededIDsKey) ?? []).isEmpty
    }

    // MARK: - Seed

    @discardableResult
    static func seed(into ctx: ModelContext, existing: [WorkoutLog]) -> Int {
        guard !isSeeded else { return 0 }

        let cal = etCalendar
        let today = cal.startOfDay(for: Date())
        guard let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: today)?.start
        else { return 0 }

        // Composite-key dedup, same approach as DataExportService.mergeImport.
        struct Key: Hashable { let day: String; let y: Int; let m: Int; let d: Int }
        func key(day: String, date: Date) -> Key {
            let c = cal.dateComponents([.year, .month, .day], from: date)
            return Key(day: day, y: c.year ?? 0, m: c.month ?? 0, d: c.day ?? 0)
        }
        let existingKeys = Set(existing.map { key(day: $0.day, date: $0.date) })

        let weekdayOffset: [ProgrammeDay: Int] = [
            .mon: 0, .tue: 1, .wed: 2, .thu: 3, .fri: 4, .sat: 5, .sun: 6
        ]

        var seededIDs: [String] = []
        var created = 0

        // Weeks: 4 back through current, oldest first so progression reads
        // naturally in charts.
        for weeksBack in stride(from: 4, through: 0, by: -1) {
            guard let weekStart = cal.date(byAdding: .day, value: -7 * weeksBack, to: thisWeekStart)
            else { continue }
            let progression = Double(4 - weeksBack) * 5.0   // ~5 lb per week

            for day in LogContent.orderedDays {
                guard let offset = weekdayOffset[day],
                      let date = cal.date(byAdding: .day, value: offset, to: weekStart)
                else { continue }
                // Never seed the future or collide with real logs.
                guard date <= today else { continue }
                guard !existingKeys.contains(key(day: day.rawValue, date: date)) else { continue }

                let log = WorkoutLog(date: date, day: day.rawValue)
                ctx.insert(log)

                for (exIdx, ex) in (LogContent.exercises[day] ?? []).enumerated() {
                    let base = baseWeight(for: ex.name)
                    for setNum in 1...ex.sets {
                        // Deterministic variation: later sets slightly fewer reps.
                        let reps = max(6, 10 - setNum + (exIdx % 2))
                        let weight = base + progression
                        let entry = SetEntry(
                            exerciseName: ex.name,
                            setNumber: setNum,
                            weight: weight,
                            reps: reps,
                            log: log
                        )
                        ctx.insert(entry)
                        log.sets.append(entry)
                    }
                }

                seededIDs.append(log.id.uuidString)
                created += 1
            }
        }

        try? ctx.save()
        UserDefaults.standard.set(seededIDs, forKey: seededIDsKey)

        // Fake WHOOP snapshot — only when nothing real is cached.
        if WhoopTodayCache.load() == nil {
            WhoopTodayCache.save(WhoopTodaySnapshot(
                fetchedAt: Date(),
                recoveryScore: 78,
                hrvMilli: 52,
                hrvBaselineMilli: 49,
                sleepPerformance: 85,
                sleepHours: 7.4,
                dayStrain: 12.3,
                weeklyRecoveryAvg: 71,
                weeklyHrvAvg: 50,
                weeklySleepHoursAvg: 7.1,
                weeklyStrainAvg: 11.8
            ))
            UserDefaults.standard.set(true, forKey: wroteSnapshotKey)
        }

        return created
    }

    // MARK: - Unseed

    @discardableResult
    static func unseed(from ctx: ModelContext, logs: [WorkoutLog]) -> Int {
        let ids = Set(UserDefaults.standard.stringArray(forKey: seededIDsKey) ?? [])
        guard !ids.isEmpty else { return 0 }

        var removed = 0
        for log in logs where ids.contains(log.id.uuidString) {
            ctx.delete(log)
            removed += 1
        }
        try? ctx.save()
        UserDefaults.standard.removeObject(forKey: seededIDsKey)

        if UserDefaults.standard.bool(forKey: wroteSnapshotKey) {
            WhoopTodayCache.clear()
            UserDefaults.standard.removeObject(forKey: wroteSnapshotKey)
        }

        return removed
    }

    // MARK: - Plausible weights

    private static func baseWeight(for exercise: String) -> Double {
        let n = exercise.lowercased()
        if n.contains("deadlift") || n.contains("rdl") { return 225 }
        if n.contains("squat") { return 185 }
        if n.contains("leg press") { return 270 }
        if n.contains("bench") { return 155 }
        if n.contains("row") { return 120 }
        if n.contains("pulldown") || n.contains("pull-down") { return 110 }
        if n.contains("press") { return 90 }
        if n.contains("curl") { return 30 }
        if n.contains("fly") || n.contains("raise") || n.contains("extension") { return 25 }
        if n.contains("face pull") || n.contains("pull-through") { return 40 }
        if n.contains("slam") || n.contains("throw") || n.contains("med ball") { return 20 }
        return 45
    }
}
