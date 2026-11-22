import Foundation

struct LoggableExercise: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let sets: Int
    init(_ name: String, _ sets: Int) { self.name = name; self.sets = sets }
}

enum LogContent {
    static let orderedDays: [ProgrammeDay] = [.mon, .tue, .thu, .fri, .sat]

    static let dayDisplay: [ProgrammeDay: String] = [
        .mon: "Mon·Back+Chest",
        .tue: "Tue·Legs",
        .thu: "Thu·Arms+Shoulders",
        .fri: "Fri·Athletic Upper",
        .sat: "Sat·Athletic Conditioning"
    ]
}

/// Tuesday Lift A: Trap Bar Squat or Barbell Back Squat, chosen in the Log
/// tab or on the Tuesday card in Lifts and stored in AppStorage. Each
/// variant is logged under its own name, so each keeps its own history.
enum LiftVariant: String, CaseIterable, Identifiable {
    // Raw values are the log names and the stored AppStorage values: never rename.
    case trapBar = "Trap Bar Squat"
    case backSquat = "Barbell Back Squat"

    var id: String { rawValue }

    static let storageKey = "tueLiftAVariant"
    /// Used when nothing valid is stored.
    static let fallback: LiftVariant = .backSquat
    /// The programme slot the variant replaces.
    static let slotID = "tue-a"

    /// The one place the stored value is turned into a variant.
    static func resolve(stored: String) -> LiftVariant {
        LiftVariant(rawValue: stored) ?? fallback
    }

    var def: ExerciseDef {
        switch self {
        case .trapBar: return Programme.tueLiftATrapBar
        case .backSquat: return Programme.tueLiftABackSquat
        }
    }
}

extension Programme {
    static func content(for day: ProgrammeDay) -> DayContent {
        switch day {
        case .mon: return monday
        case .tue: return tuesday
        case .wed: return wednesday
        case .thu: return thursday
        case .fri: return friday
        case .sat: return saturday
        case .sun: return sunday
        }
    }

    /// Every ExerciseDef in a day, in the order the day card shows them.
    static func exerciseDefs(for day: ProgrammeDay) -> [ExerciseDef] {
        content(for: day).sections.flatMap { section -> [ExerciseDef] in
            switch section {
            case .groups(let blocks): return blocks.flatMap(\.exercises)
            case .abCircuit(_, _, let items): return items
            default: return []
            }
        }
    }

    /// What the Log tab offers for a day: the day's logged exercises in
    /// programme order. With a variant, Tuesday's Lift A slot is that
    /// variant; without one, the day as written (Trap Bar Squat).
    static func loggable(for day: ProgrammeDay, variant: LiftVariant? = nil) -> [LoggableExercise] {
        exerciseDefs(for: day).compactMap { def in
            let def = (variant != nil && def.id == LiftVariant.slotID) ? variant!.def : def
            return loggable(def)
        }
    }

    /// The log entry for one exercise, or nil when it isn't logged.
    static func loggable(_ def: ExerciseDef) -> LoggableExercise? {
        guard case .name(let name, let override)? = def.logAs else { return nil }
        // A logged exercise with neither an override nor an "N×" chip is
        // caught by ProgrammeLogTests; 3 only keeps the screen usable.
        return LoggableExercise(name, override ?? setCount(fromChips: def.chips) ?? 3)
    }

    /// The set count in a leading chip such as "4×6-8" or "2×40 yd".
    static func setCount(fromChips chips: [String]) -> Int? {
        guard let first = chips.first, let x = first.firstIndex(of: "×") else { return nil }
        let digits = first[first.startIndex..<x]
        guard !digits.isEmpty, digits.allSatisfy(\.isNumber), let n = Int(digits), n > 0 else { return nil }
        return n
    }
}
