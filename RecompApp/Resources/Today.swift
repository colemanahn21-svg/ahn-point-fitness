import Foundation

struct StatBox: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct SaunaEntry: Identifiable {
    enum Kind { case tue, wed, sat, skip }
    let id = UUID()
    let kind: Kind
    let short: String
    let title: String
    let body: String
}

enum TodayContent {
    static let stats: [StatBox] = [
        .init(value: "68%",   label: "Avg Recovery"),
        .init(value: "48ms",  label: "Avg HRV"),
        .init(value: "51bpm", label: "Avg RHR"),
        .init(value: "11.4",  label: "Avg Day Strain"),
        .init(value: "6.7hr", label: "Avg Sleep"),
        .init(value: "76%",   label: "Sleep Perf")
    ]

    static let zoneGreen: [ZoneRule] = [
        .init(label: "Lift", body: "Full session, push RPE to top of target range."),
        .init(label: "Finisher", body: "Full ab circuit (2 rounds) or full cardio."),
        .init(label: "Nutrition", body: "Training day cals (~2,300). Full carbs.")
    ]

    static let zoneYellow: [ZoneRule] = [
        .init(label: "Lift", body: "Full session. Mid-range RPE (7–8). No PRs."),
        .init(label: "Finisher", body: "Ab circuit 2 rounds. Cardio 12–15 min only."),
        .init(label: "Nutrition", body: "Training day cals. Prioritise protein timing.")
    ]

    static let zoneRed: [ZoneRule] = [
        .init(label: "Lift", body: "Drop 1 set per exercise. RPE 6–7 max."),
        .init(label: "Finisher", body: "Skip ab circuit AND cardio entirely."),
        .init(label: "Nutrition", body: "Eat at maintenance. Extra carbs + sleep tonight.")
    ]

    static let threeDayRedRule = (
        title: "3-Day Red Rule",
        body: "If WHOOP shows red 3+ days in a row, take a full rest day. Your HRV is likely below 35 ms. Resume when you see yellow or green."
    )

    static let hrvHowThisPlanRaises: [InfoParagraph] = [
        .init(segments: [
            .bold("Sleep:"),
            .text(" Moving bedtime from 1:30→12:30 AM should lift HRV 8–15 ms within 2–3 weeks (your data: 7.5+ hrs = 67% recovery vs 31% under 5.5 hrs).")
        ]),
        .init(segments: [
            .bold("Zone 2 cardio 3x/wk:"),
            .text(" Builds parasympathetic tone. Expect VO2max to improve 3–5% over 8 weeks.")
        ]),
        .init(segments: [
            .bold("Never to failure:"),
            .text(" RPE 7–8.5 preserves hypertrophy stimulus while allowing faster HRV recovery.")
        ]),
        .init(segments: [
            .bold("Target:"),
            .text(" Move 30-day HRV from 44 ms → 55–60 ms by Week 8.")
        ])
    ]

    static let vo2Push: [InfoParagraph] = [
        .init(segments: [
            .text("During Friday's cardio finisher, add "),
            .bold("3–4 × 30-second pushes"),
            .text(" to Zone 3–4 (150–170 bpm) with 90s easy recovery between. This is your weekly cardiac overload stimulus.")
        ])
    ]

    static let sauna: [SaunaEntry] = [
        .init(kind: .tue, short: "TUE",
              title: "Post-Legs · 15 min",
              body: "After cardio finisher + stretch. Flushes metabolic waste from squats/RDLs. Elevates growth hormone 2–3× baseline."),
        .init(kind: .wed, short: "WED",
              title: "Rest Day · 20 min",
              body: "After optional cardio or standalone. Deepest recovery day — promotes parasympathetic activation and lifts next-day HRV."),
        .init(kind: .sat, short: "SAT",
              title: "Post-Athletic · 15 min",
              body: "After conditioning + mobility. Cardiovascular recovery, not muscle repair. Heat acclimation improves plasma volume → supports VO2max."),
        .init(kind: .skip, short: "SKIP",
              title: "Mon, Thu, Fri, Sun",
              body: "Mon/Thu: abs on turf after lifts, no time. Fri: HIFT already spikes core temp. Sun: full rest, stay home.")
    ]
}
