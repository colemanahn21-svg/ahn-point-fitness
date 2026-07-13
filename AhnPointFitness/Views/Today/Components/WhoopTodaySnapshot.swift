import Foundation

// MARK: - Snapshot (derived view model + on-disk cache shape)

struct WhoopTodaySnapshot: Codable {
    let fetchedAt: Date
    let recoveryScore: Int?            // 0-100
    let hrvMilli: Double?              // today
    let hrvBaselineMilli: Double?      // mean of last 30 days
    let sleepPerformance: Int?         // 0-100
    let sleepHours: Double?
    let dayStrain: Double?

    // 7-day rolling averages (optional → backwards compatible with v1 cache)
    let weeklyRecoveryAvg: Int?
    let weeklyHrvAvg: Double?
    let weeklySleepHoursAvg: Double?
    let weeklyStrainAvg: Double?

    var hrvDelta: Double? {
        guard let h = hrvMilli, let b = hrvBaselineMilli else { return nil }
        return h - b
    }

    /// Monday 00:00 of the current calendar week, in America/New_York.
    /// Used as the inclusive lower bound for weekly aggregates.
    static func currentWeekStartET(now: Date = Date()) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        cal.firstWeekday = 2  // Monday
        return cal.dateInterval(of: .weekOfYear, for: now)?.start
            ?? now.addingTimeInterval(-7 * 86_400)
    }

    static func compute(
        recoveries: [RecoveryRecord],
        cycles: [CycleRecord],
        sleeps: [SleepRecord]
    ) -> WhoopTodaySnapshot {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Latest recovery (by created_at)
        let latestRecovery = recoveries.max { (a, b) in
            (f.date(from: a.created_at) ?? .distantPast) <
            (f.date(from: b.created_at) ?? .distantPast)
        }
        let recoveryScore = latestRecovery?.score?.recovery_score
            .map { Int($0.rounded()) }
        let hrv = latestRecovery?.score?.hrv_rmssd_milli

        // 30-day HRV baseline = mean of available HRV values
        let hrvValues = recoveries.compactMap { $0.score?.hrv_rmssd_milli }
        let hrvBaseline: Double? = hrvValues.isEmpty
            ? nil
            : hrvValues.reduce(0, +) / Double(hrvValues.count)

        // Latest sleep (by start)
        let latestSleep = sleeps.max { (a, b) in
            (f.date(from: a.start) ?? .distantPast) <
            (f.date(from: b.start) ?? .distantPast)
        }
        let sleepPerf = latestSleep?.score?.sleep_performance_percentage
            .map { Int($0.rounded()) }
        let sleepHours: Double? = latestSleep.flatMap { s -> Double? in
            guard let stages = s.score?.stage_summary,
                  let inBed = stages.total_in_bed_time_milli else { return nil }
            let awake = stages.total_awake_time_milli ?? 0
            let asleepMs = inBed - awake
            return asleepMs > 0 ? Double(asleepMs) / 3_600_000.0 : nil
        }

        // Latest cycle's strain (by start)
        let latestCycle = cycles.max { (a, b) in
            (f.date(from: a.start) ?? .distantPast) <
            (f.date(from: b.start) ?? .distantPast)
        }
        let strain = latestCycle?.score?.strain

        // ─── Current week averages (Monday → Sunday, ET) ─────────────────
        let weekStart = WhoopTodaySnapshot.currentWeekStartET()

        // Recoveries within current week
        let weekRecoveries = recoveries.filter {
            (f.date(from: $0.created_at) ?? .distantPast) >= weekStart
        }
        let weeklyRecoveryAvg: Int? = {
            let scores = weekRecoveries.compactMap { $0.score?.recovery_score }
            guard !scores.isEmpty else { return nil }
            return Int((scores.reduce(0, +) / Double(scores.count)).rounded())
        }()
        let weeklyHrvAvg: Double? = {
            let vals = weekRecoveries.compactMap { $0.score?.hrv_rmssd_milli }
            guard !vals.isEmpty else { return nil }
            return vals.reduce(0, +) / Double(vals.count)
        }()

        // Sleeps within current week
        let weekSleeps = sleeps.filter {
            (f.date(from: $0.start) ?? .distantPast) >= weekStart
        }
        let weeklySleepHoursAvg: Double? = {
            let hours = weekSleeps.compactMap { sleep -> Double? in
                guard let stages = sleep.score?.stage_summary,
                      let inBed = stages.total_in_bed_time_milli else { return nil }
                let awake = stages.total_awake_time_milli ?? 0
                let asleepMs = inBed - awake
                return asleepMs > 0 ? Double(asleepMs) / 3_600_000.0 : nil
            }
            guard !hours.isEmpty else { return nil }
            return hours.reduce(0, +) / Double(hours.count)
        }()

        // Cycles within current week
        let weekCycles = cycles.filter {
            (f.date(from: $0.start) ?? .distantPast) >= weekStart
        }
        let weeklyStrainAvg: Double? = {
            let strains = weekCycles.compactMap { $0.score?.strain }
            guard !strains.isEmpty else { return nil }
            return strains.reduce(0, +) / Double(strains.count)
        }()

        return WhoopTodaySnapshot(
            fetchedAt: Date(),
            recoveryScore: recoveryScore,
            hrvMilli: hrv,
            hrvBaselineMilli: hrvBaseline,
            sleepPerformance: sleepPerf,
            sleepHours: sleepHours,
            dayStrain: strain,
            weeklyRecoveryAvg: weeklyRecoveryAvg,
            weeklyHrvAvg: weeklyHrvAvg,
            weeklySleepHoursAvg: weeklySleepHoursAvg,
            weeklyStrainAvg: weeklyStrainAvg
        )
    }
}
