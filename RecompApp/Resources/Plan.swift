import Foundation
import SwiftUI

struct OverloadWeek: Identifiable {
    let id = UUID()
    let wk: String
    let desc: AttributedDesc
    let rpe: String
    let highlight: Highlight
    enum Highlight { case none, deload, taper }

    struct AttributedDesc {
        let bold: String?
        let body: String
    }
}

struct AbProgItem: Identifiable {
    let id = UUID()
    let slot: String
    let before: String
    let after: String
}

enum PlanContent {
    static let overload: [OverloadWeek] = [
        .init(wk: "W1", desc: .init(bold: nil, body: "Bottom of rep range. Establish baseline weights."), rpe: "RPE 7", highlight: .none),
        .init(wk: "W2", desc: .init(bold: nil, body: "+5 lb or +1 rep. Same weight, more reps."), rpe: "7.5–8", highlight: .none),
        .init(wk: "W3", desc: .init(bold: nil, body: "Top of rep range. Push to rep ceiling."), rpe: "8–8.5", highlight: .none),
        .init(wk: "W4", desc: .init(bold: "DELOAD:", body: " 60% load, 50% volume. Eat maintenance."), rpe: "5–6", highlight: .deload),
        .init(wk: "W5", desc: .init(bold: nil, body: "New weight, bottom of range. Reset + add load."), rpe: "7.5–8", highlight: .none),
        .init(wk: "W6", desc: .init(bold: nil, body: "+5 lb or +1 rep. Push intensity."), rpe: "8–8.5", highlight: .none),
        .init(wk: "W7", desc: .init(bold: nil, body: "Top of rep range. Peak volume week."), rpe: "8.5–9", highlight: .none),
        .init(wk: "W8", desc: .init(bold: "TAPER:", body: " −30% vol, keep intensity. Carb up. Memorial Day."), rpe: "7–8", highlight: .taper)
    ]

    static let abProgMon: [AbProgItem] = [
        .init(slot: "E1", before: "Renegade Row Plank", after: "Renegade Row + Push-Up (6/side)"),
        .init(slot: "E2", before: "Russian Twist", after: "Russian Twist, feet elevated"),
        .init(slot: "E3", before: "Body Saw", after: "Body Saw + plate on back"),
        .init(slot: "E4", before: "Dead Bug w/ plate", after: "Dead Bug + leg lower"),
        .init(slot: "E5", before: "Plank Pull-Through", after: "Commando Plank w/ drag")
    ]

    static let abProgThu: [AbProgItem] = [
        .init(slot: "E1", before: "Sit-Up plate on chest", after: "Plate behind head (12–15)"),
        .init(slot: "E2", before: "DB Side Bend", after: "DB Suitcase Crunch (10/side)"),
        .init(slot: "E3", before: "OH Sit-Up", after: "OH Sit-Up + press at top"),
        .init(slot: "E4", before: "V-Up", after: "Weighted V-Up w/ plate"),
        .init(slot: "E5", before: "Side Plank + Reach", after: "Copenhagen + DB Reach")
    ]

    static let abProgSat: [AbProgItem] = [
        .init(slot: "E1", before: "Reverse Crunch w/ plate", after: "DB between feet (12–15)"),
        .init(slot: "E2", before: "Plate Toe Touch", after: "+ 3s hold at top (12)"),
        .init(slot: "E3", before: "Woodchop half-kneel", after: "Standing (10/side)"),
        .init(slot: "E4", before: "Flutter Kick", after: "+ plate on chest"),
        .init(slot: "E5", before: "Suitcase Carry", after: "Waiter + Suitcase combo")
    ]

    static let deload: [String] = [
        "Sets: 4 → 2. Load: 60–65%. RPE 5–6 max.",
        "Ab circuits: 1 round. Cardio: 10 min, 2 sessions (skip Wed).",
        "Eat at maintenance (~2,350 kcal). No deficit.",
        "Push for 8+ hrs sleep every night."
    ]

    static let taper: [String] = [
        "Keep weight on bar high. Cut volume 30–40%.",
        "Train Mon–Thu. Rest Fri–Sun.",
        "Surplus: ~2,600 kcal/day. Carbs: 2.5–3 g/lb (430–550g).",
        "You'll gain 1–2 lb water from glycogen = bigger, fuller look.",
        "Reduce sodium Thu–Sat for a harder look."
    ]

    struct TimelineRow {
        let week: String
        let color: Color
        let body: String
    }

    static let timeline: [TimelineRow] = [
        .init(week: "W4", color: Theme.yellow, body: "182–186 lb · ~13–14% BF · Upper 4 abs visible · HRV 48–55 ms"),
        .init(week: "W8", color: Theme.green,  body: "175–182 lb · ~12–13% BF · Full abs · Vascularity · HRV 52–60 ms")
    ]
}
