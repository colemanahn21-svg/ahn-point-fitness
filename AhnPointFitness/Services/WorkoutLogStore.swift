import Foundation
import SwiftData

/// The weight and reps text typed on the Log tab or in the editor, per
/// exercise per set. A value type: the views edit it, the store saves it.
struct SetSheet: Equatable {
    enum Field: String { case weight = "w", reps = "r" }

    /// exerciseName -> "w-1", "r-1", ... -> text as typed.
    private var cells: [String: [String: String]] = [:]

    init() {}

    /// The sheet a saved log fills in (all of its sets, every exercise).
    init(log: WorkoutLog?) {
        guard let log else { return }
        for s in log.sets {
            if let w = s.weight { self[s.exerciseName, .weight, s.setNumber] = formatWeight(w) }
            if let r = s.reps { self[s.exerciseName, .reps, s.setNumber] = String(r) }
        }
    }

    subscript(exercise: String, field: Field, setNumber: Int) -> String {
        get { cells[exercise]?["\(field.rawValue)-\(setNumber)"] ?? "" }
        set { cells[exercise, default: [:]]["\(field.rawValue)-\(setNumber)"] = newValue }
    }
}

/// Finding and saving workout logs, kept out of the views so the Log tab
/// and the editor share one tested path.
enum WorkoutLogStore {
    /// The log for a programme day on the ET calendar day containing `date`.
    static func log(for day: ProgrammeDay, on date: Date, in logs: [WorkoutLog]) -> WorkoutLog? {
        logs.first { $0.day == day.rawValue && ET.isSameDay($0.date, date) }
    }

    /// Saves the visible exercises' sets.
    ///
    /// - `existing`: the log to edit; nil makes a new log dated at ET
    ///   midnight of `date`.
    /// - Only the sets of `exercises` are replaced. Sets for other names on
    ///   the same log (the other Tuesday Lift A variant) are kept.
    /// - A set row with neither weight nor reps is skipped.
    /// - On failure every change is rolled back and the error is thrown.
    @discardableResult
    static func save(
        _ sheet: SetSheet,
        exercises: [LoggableExercise],
        day: ProgrammeDay,
        date: Date,
        existing: WorkoutLog?,
        in ctx: ModelContext,
        commit: (ModelContext) throws -> Void = { try $0.save() }
    ) throws -> WorkoutLog {
        let log = existing ?? WorkoutLog(date: ET.startOfDay(date), day: day.rawValue)
        if log.modelContext == nil {
            ctx.insert(log)
        }

        let visibleNames = Set(exercises.map(\.name))
        for s in log.sets where visibleNames.contains(s.exerciseName) {
            ctx.delete(s)
        }
        log.sets.removeAll { visibleNames.contains($0.exerciseName) }

        for ex in exercises {
            for n in 1...max(ex.sets, 1) {
                let wText = sheet[ex.name, .weight, n].trimmingCharacters(in: .whitespacesAndNewlines)
                let rText = sheet[ex.name, .reps, n].trimmingCharacters(in: .whitespacesAndNewlines)
                guard !wText.isEmpty || !rText.isEmpty else { continue }
                let entry = SetEntry(exerciseName: ex.name, setNumber: n,
                                     weight: parseWeight(wText), reps: parseReps(rText), log: log)
                ctx.insert(entry)
                log.sets.append(entry)
            }
        }

        do {
            try commit(ctx)
        } catch {
            ctx.rollback()
            throw error
        }
        return log
    }

    /// "135", " 135.5 ", "135,5" -> 135.5. Empty or unreadable -> nil.
    static func parseWeight(_ text: String) -> Double? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !t.isEmpty, let w = Double(t), w.isFinite else { return nil }
        return w
    }

    /// " 8 " -> 8. Empty or unreadable -> nil.
    static func parseReps(_ text: String) -> Int? {
        Int(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
