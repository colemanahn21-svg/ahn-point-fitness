import SwiftUI

struct WhoopProgressionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InfoBlock(
                title: "Period",
                paragraphs: [
                    .init(segments: [
                        .text("Mar 30 – May 11, 2026 · "),
                        .bold("42 cycles"),
                        .text(" · 36 workouts (22 lifts, 9 golf, 3 runs, 2 dance) · 25 green / 14 yellow / 3 red days.")
                    ])
                ]
            )

            InfoBlock(
                title: "Trend (first 3 wk → last 3 wk)",
                paragraphs: [
                    .init(segments: [
                        .bold("Recovery: "),
                        .text("72.5% → 64.1% "),
                        .bold("(−8.4)")
                    ]),
                    .init(segments: [
                        .bold("HRV: "),
                        .text("47 → 48 ms "),
                        .bold("(+1)")
                    ]),
                    .init(segments: [
                        .bold("RHR: "),
                        .text("50 → 52 bpm "),
                        .bold("(+2)")
                    ]),
                    .init(segments: [
                        .bold("Day Strain: "),
                        .text("10.9 → 12.0 "),
                        .bold("(+1.1)")
                    ]),
                    .init(segments: [
                        .bold("Sleep: "),
                        .text("6.6 → 6.8 hr "),
                        .bold("(+0.2)")
                    ]),
                    .init(segments: [
                        .bold("Sleep debt: "),
                        .text("103 → 111 min "),
                        .bold("(+8)")
                    ])
                ]
            )

            InfoBlock(
                title: "What the data is telling you",
                paragraphs: [
                    .init(segments: [
                        .bold("Strain is climbing faster than recovery is keeping up. "),
                        .text("Average day strain rose ~10% while average recovery dropped 8 points. Classic accumulation pattern — you're training more but not banking the recovery to match.")
                    ]),
                    .init(segments: [
                        .bold("HRV holding flat is the bright spot. "),
                        .text("Despite higher load, HRV barely moved (47 → 48 ms). Your aerobic system is absorbing the work; central fatigue is what's bleeding into recovery score.")
                    ]),
                    .init(segments: [
                        .bold("RHR drift is the warning. "),
                        .text("Resting HR climbed 2 bpm — small, but trending the wrong way. Combined with the strain bump, that's your body asking for more sleep, not more training.")
                    ]),
                    .init(segments: [
                        .bold("Sleep is the lever. "),
                        .text("You averaged 6.7 hr/night with a chronic 107-min debt. Adding 30–45 min/night for two weeks should flip recovery back into the green and stop the RHR creep.")
                    ]),
                    .init(segments: [
                        .bold("Zone distribution is solid — but slipping. "),
                        .text("60% green / 33% yellow / 7% red over 42 days is healthy, but the last 3 weeks have tilted toward yellow. Don't let three consecutive yellows turn into a red streak.")
                    ])
                ]
            )
        }
    }
}
