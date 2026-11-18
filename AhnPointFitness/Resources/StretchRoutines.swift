import Foundation
import SwiftUI

// MARK: - Routine content model

struct StretchStep: Identifiable {
    let id: String
    let name: String
    let detail: String
    let chips: [String]
    let timing: StretchTiming

    /// Illustration(s) for this movement, if added to the catalogue.
    var art: StretchArtSet? { StretchArt.artSet(for: name) }

    /// Skimmable setup cues. The long-form `detail` stays available behind
    /// the Why toggle — these are what you read mid-hold.
    var cues: [String] { StretchCues.cues(for: name) }

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
        case golf, postLift, fullBody, preRound, desk, home
        var symbol: String {
            switch self {
            case .desk: return "desktopcomputer"
            case .home: return "house"
            case .golf: return "figure.golf"
            case .postLift: return "dumbbell"
            case .fullBody: return "figure.flexibility"
            case .preRound: return "bolt.fill"
            }
        }
    }

    /// How the player paces a routine. A flow is breath-led: no 3-2-1
    /// ticks, one soft chime when it is time to move, and only a 3s gap to
    /// roll to the other side. Intervals keep the countdown — right for a
    /// dynamic warm-up, wrong for something meant to feel like a class.
    enum Cadence { case flow, interval }

    let id: String
    let name: String
    let subtitle: String
    let focus: Focus
    let phases: [StretchPhase]
    var cadence: Cadence = .flow

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
    /// Rolling to the other side needs less than a full set-up in a flow.
    static let sideSwitchSeconds = 3
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
                    let gap = (side == .right && routine.cadence == .flow)
                        ? sideSwitchSeconds : getReadySeconds
                    segments.append(StretchSegment(
                        id: id, kind: .getReady, step: step, stepIndex: stepIndex,
                        phaseLabel: phase.label, side: side, seconds: gap))
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

enum StretchLibrary {
    /// One flow for every upper-body lift day. The content lives with the
    /// programme (Lifts+UpperBodyFlow.swift); this wraps it for the player.
    static let upperBody = StretchRoutine(
        id: "flow.upper",
        name: "Upper Body Flow",
        subtitle: "Standing to floor · after upper-body lifts",
        focus: .postLift,
        phases: Programme.upperBodyFlow.map { block in
            StretchPhase(id: "flow.upper.\(block.label)", label: block.label,
                         steps: block.stretches.map { StretchStep($0, idPrefix: "upper") })
        })

    static let lowerBody = StretchRoutine(
        id: "flow.lower",
        name: "Lower Body Flow",
        subtitle: "Standing to floor · after legs and conditioning",
        focus: .postLift,
        phases: Programme.lowerBodyFlow.map { block in
            StretchPhase(id: "flow.lower.\(block.label)", label: block.label,
                         steps: block.stretches.map { StretchStep($0, idPrefix: "lower") })
        })

    static var golfRoutines: [StretchRoutine] {
        [Golf.rotationFlow, Golf.preRound]
    }

    static var workRoutines: [StretchRoutine] {
        [Work.deskReset]
    }

    static var postLiftRoutines: [StretchRoutine] { [upperBody, lowerBody] }

    static var all: [StretchRoutine] { golfRoutines + workRoutines + postLiftRoutines }

    static func routine(id: String) -> StretchRoutine? { all.first { $0.id == id } }

    /// The one routine scheduled for a day. See `StretchSchedule`.
    static func routine(for day: ProgrammeDay) -> StretchRoutine {
        StretchSchedule.evening(for: day)
    }
}

// MARK: - Weekly schedule

/// One home routine a day, picked by the day rather than by mood.
///
/// A menu of nine routines got none of them done: every choice was a chance
/// to skip, and doing everything prescribed came to about an hour a day. Three
/// home flows repeat across the week so each becomes familiar, and the desk
/// reset rides along on workdays because it costs nothing to start.
///
/// - Upper-body lift days run Upper Body Flow, which already carries the
///   thoracic work (couch sink, thread + open, roller), so the golf flow is
///   not needed on top.
/// - The two lower-body days (Tue legs, Sat conditioning) run Lower Body
///   Flow: hamstrings, soleus, quads, adductors, glutes.
/// - Wed and Sun run the Golf Rotation Flow. Twice is enough because the
///   thoracic spine is also worked by the desk reset every weekday and by
///   Upper Body Flow three times a week.
/// - The desk reset includes a seated hamstring hinge, so hamstrings get a
///   dose five days a week, not just after RDLs.
enum StretchSchedule {
    static func evening(for day: ProgrammeDay) -> StretchRoutine {
        switch day {
        case .mon, .thu, .fri: return StretchLibrary.upperBody
        case .tue, .sat: return StretchLibrary.lowerBody
        case .wed, .sun: return StretchLibrary.Golf.rotationFlow
        }
    }

    /// Weekdays add the Desk Reset, once, after lunch.
    static func desk(for day: ProgrammeDay) -> StretchRoutine? {
        switch day {
        case .sat, .sun: return nil
        default: return StretchLibrary.Work.deskReset
        }
    }

    /// The days a routine is scheduled, in week order.
    static func days(for routine: StretchRoutine) -> [ProgrammeDay] {
        ProgrammeDay.allCases.filter {
            evening(for: $0).id == routine.id || desk(for: $0)?.id == routine.id
        }
    }

    /// "Mon · Thu · Fri", or "Weekdays" / "Every day" when that is shorter.
    static func daysLabel(for routine: StretchRoutine) -> String? {
        let days = days(for: routine)
        if days.isEmpty { return nil }
        if days.count == 7 { return "Every day" }
        if days == [.mon, .tue, .wed, .thu, .fri] { return "Weekdays · after lunch" }
        return days.map(\.short).joined(separator: " · ")
    }

    /// Today's programme day, in Eastern time like the rest of the app.
    static func today(_ now: Date = .now) -> ProgrammeDay {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        switch cal.component(.weekday, from: now) {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        default: return .sat
        }
    }
}
