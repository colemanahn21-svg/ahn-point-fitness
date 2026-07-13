import Foundation

// MARK: - Pure value types (no SwiftData dependency)

struct SetSnapshot: Hashable {
    let weight: Double
    let reps: Int
    let setNumber: Int
}

struct TopSet: Hashable {
    let weight: Double
    let reps: Int
    let date: Date
    let logID: UUID
}

struct SessionData: Identifiable, Hashable {
    let id: UUID            // logID
    let date: Date
    let sets: [SetSnapshot] // sorted by setNumber asc
    let topSet: SetSnapshot
}

struct ExerciseStats {
    let exerciseName: String
    let totalSessions: Int
    let pr: TopSet?
    let last: TopSet?
    let sessions: [SessionData]   // chronological asc
    let flatTrend: Bool
    let lbGained: Double
    let percentGain: Int
    let prSessionLogID: UUID?

    var hasHistory: Bool { totalSessions > 0 }
    var hasMultipleSessions: Bool { totalSessions >= 2 }

    static let empty = ExerciseStats(
        exerciseName: "",
        totalSessions: 0,
        pr: nil,
        last: nil,
        sessions: [],
        flatTrend: false,
        lbGained: 0,
        percentGain: 0,
        prSessionLogID: nil
    )
}

// MARK: - Best-set comparator (weight first, reps as tiebreaker)

private func isBetter(_ a: SetSnapshot, than b: SetSnapshot) -> Bool {
    if a.weight != b.weight { return a.weight > b.weight }
    return a.reps > b.reps
}

private func bestOf(_ sets: [SetSnapshot]) -> SetSnapshot? {
    sets.reduce(nil as SetSnapshot?) { acc, s in
        guard let cur = acc else { return s }
        return isBetter(s, than: cur) ? s : cur
    }
}

// MARK: - Compute

extension ExerciseStats {
    /// Pure: takes any sequence of WorkoutLog and returns derived stats for the named exercise.
    /// Filters: skips sets where weight or reps is nil; skips logs with no valid sets.
    static func compute(for exerciseName: String, from logs: [WorkoutLog]) -> ExerciseStats {
        // Build SessionData per log that has at least one valid set for this exercise.
        let unsorted: [SessionData] = logs.compactMap { log in
            let valid: [SetSnapshot] = log.sets.compactMap { entry in
                guard entry.exerciseName == exerciseName,
                      let w = entry.weight,
                      let r = entry.reps else { return nil }
                return SetSnapshot(weight: w, reps: r, setNumber: entry.setNumber)
            }
            guard !valid.isEmpty, let top = bestOf(valid) else { return nil }
            let sortedSets = valid.sorted { $0.setNumber < $1.setNumber }
            return SessionData(id: log.id, date: log.date, sets: sortedSets, topSet: top)
        }

        let sessions = unsorted.sorted { $0.date < $1.date }

        // PR: best top-set across sessions (weight, then reps).
        let prSession = sessions.reduce(nil as SessionData?) { acc, s in
            guard let cur = acc else { return s }
            return isBetter(s.topSet, than: cur.topSet) ? s : cur
        }
        let pr = prSession.map {
            TopSet(weight: $0.topSet.weight, reps: $0.topSet.reps, date: $0.date, logID: $0.id)
        }

        // Last: top set of the most recent session.
        let lastSession = sessions.last
        let last = lastSession.map {
            TopSet(weight: $0.topSet.weight, reps: $0.topSet.reps, date: $0.date, logID: $0.id)
        }

        // Flat trend: 3+ sessions AND last 2 sessions both strictly below PR weight.
        var flatTrend = false
        if let prW = pr?.weight, sessions.count >= 3 {
            let lastTwo = sessions.suffix(2)
            flatTrend = lastTwo.allSatisfy { $0.topSet.weight < prW }
        }

        // lb / % gain from first session top set to last session top set.
        let lbGained: Double
        let percentGain: Int
        if let first = sessions.first, let lastS = lastSession, sessions.count >= 2 {
            lbGained = lastS.topSet.weight - first.topSet.weight
            if first.topSet.weight > 0 {
                let pct = (lastS.topSet.weight - first.topSet.weight) / first.topSet.weight * 100.0
                percentGain = Int(pct.rounded())
            } else {
                percentGain = 0
            }
        } else {
            lbGained = 0
            percentGain = 0
        }

        return ExerciseStats(
            exerciseName: exerciseName,
            totalSessions: sessions.count,
            pr: pr,
            last: last,
            sessions: sessions,
            flatTrend: flatTrend,
            lbGained: lbGained,
            percentGain: percentGain,
            prSessionLogID: prSession?.id
        )
    }
}
