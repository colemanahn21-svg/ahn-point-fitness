import Foundation

// MARK: - Routine content model

struct StretchStep: Identifiable {
    let id: String
    let name: String
    let detail: String
    let chips: [String]
    let timing: StretchTiming

    init(id: String, name: String, detail: String, chips: [String]) {
        self.id = id
        self.name = name
        self.detail = detail
        self.chips = chips
        self.timing = StretchTiming.parse(chips)
    }

    init(_ def: StretchDef, idPrefix: String) {
        self.init(id: "\(idPrefix).\(def.id)", name: def.name,
                  detail: def.rationale, chips: def.chips)
    }
}

struct StretchPhase: Identifiable {
    let id: String
    let label: String
    let steps: [StretchStep]
}

struct StretchRoutine: Identifiable {
    enum Focus {
        case golf, postLift, fullBody, preRound
        var symbol: String {
            switch self {
            case .golf: return "figure.golf"
            case .postLift: return "dumbbell"
            case .fullBody: return "figure.flexibility"
            case .preRound: return "bolt.fill"
            }
        }
    }

    let id: String
    let name: String
    let subtitle: String
    let focus: Focus
    let phases: [StretchPhase]

    var steps: [StretchStep] { phases.flatMap(\.steps) }

    /// Wall-clock length including the get-ready gaps, so the time shown on
    /// the card is the time the session actually takes.
    var totalSeconds: Int { StretchTimeline.build(self).reduce(0) { $0 + $1.seconds } }

    var durationLabel: String {
        let m = Int((Double(totalSeconds) / 60).rounded())
        return "\(m) min"
    }
}

// MARK: - Timeline

enum StretchSide: String {
    case left = "Left", right = "Right"
}

struct StretchSegment: Identifiable {
    enum Kind { case getReady, work }

    let id: Int
    let kind: Kind
    let step: StretchStep
    let stepIndex: Int
    let phaseLabel: String
    let side: StretchSide?
    let seconds: Int
}

enum StretchTimeline {
    /// Seconds of "get into position" before every working segment.
    static let getReadySeconds = 5
    /// Seconds of audible countdown at the end of a working segment.
    static let countdownSeconds = 3

    static func build(_ routine: StretchRoutine) -> [StretchSegment] {
        var segments: [StretchSegment] = []
        var id = 0
        var stepIndex = 0

        for phase in routine.phases {
            for step in phase.steps {
                let sides: [StretchSide?] = step.timing.perSide ? [.left, .right] : [nil]
                for side in sides {
                    segments.append(StretchSegment(
                        id: id, kind: .getReady, step: step, stepIndex: stepIndex,
                        phaseLabel: phase.label, side: side, seconds: getReadySeconds))
                    id += 1
                    segments.append(StretchSegment(
                        id: id, kind: .work, step: step, stepIndex: stepIndex,
                        phaseLabel: phase.label, side: side, seconds: step.timing.seconds))
                    id += 1
                }
                stepIndex += 1
            }
        }
        return segments
    }
}

// MARK: - Routine catalogue

extension DayContent {
    /// The stretch blocks authored on a lift day, if any.
    var stretchBlocks: [StretchBlock] {
        for section in sections {
            if case .stretchBlocks(_, let blocks) = section { return blocks }
        }
        return []
    }
}

enum StretchLibrary {
    /// Post-lift routines, derived from the day programme so the two never
    /// drift apart — the day cards and the player read the same source data.
    static var dayRoutines: [StretchRoutine] {
        Programme.allDays.compactMap { day in
            let blocks = day.stretchBlocks
            guard !blocks.isEmpty else { return nil }

            let phases = blocks.map { block in
                StretchPhase(
                    id: "\(day.day.rawValue).\(block.label)",
                    label: block.label,
                    steps: block.stretches.map { StretchStep($0, idPrefix: day.day.rawValue) })
            }
            let count = phases.reduce(0) { $0 + $1.steps.count }
            let isFullBody = blocks.count > 1
            return StretchRoutine(
                id: "day.\(day.day.rawValue)",
                name: "\(day.day.short) · \(shortTitle(day.title))",
                subtitle: "\(count) stretches",
                focus: isFullBody ? .fullBody : .postLift,
                phases: phases)
        }
    }

    static var golfRoutines: [StretchRoutine] {
        [Golf.dailyRotationRestore, Golf.weeklyAddOns, Golf.preRound]
    }

    static var all: [StretchRoutine] { golfRoutines + dayRoutines }

    static func routine(id: String) -> StretchRoutine? { all.first { $0.id == id } }

    static func routine(for day: ProgrammeDay) -> StretchRoutine? {
        all.first { $0.id == "day.\(day.rawValue)" }
    }

    /// "Mon · Back + Chest" -> "Back + Chest"
    private static func shortTitle(_ title: String) -> String {
        guard let range = title.range(of: " · ") else { return title }
        return String(title[range.upperBound...])
    }
}
