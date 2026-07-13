import SwiftUI

struct TodayView: View {
    @StateObject private var whoop = WhoopTodayState()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "WHOOP")
            WhoopTodayCard(state: whoop)

            if let score = whoop.snapshot?.recoveryScore {
                SectionLabel(text: "Today's Rule")
                ruleForScore(score)
            }

            if let snap = whoop.snapshot, hasWeekly(snap) {
                SectionLabel(text: "Weekly Averages")
                WhoopWeeklyCard(snapshot: snap)
            }

            SectionLabel(text: "Your Baseline")
            StatGrid(stats: TodayContent.stats)
        }
    }

    private func hasWeekly(_ s: WhoopTodaySnapshot) -> Bool {
        s.weeklyRecoveryAvg != nil ||
        s.weeklyHrvAvg != nil ||
        s.weeklySleepHoursAvg != nil ||
        s.weeklyStrainAvg != nil
    }

    @ViewBuilder
    private func ruleForScore(_ score: Int) -> some View {
        if score >= 67 {
            ZoneCard(label: "GREEN (67%+)",
                     color: Theme.green, bg: Theme.greenBg,
                     rules: TodayContent.zoneGreen)
        } else if score >= 34 {
            ZoneCard(label: "YELLOW (34–66%)",
                     color: Theme.yellow, bg: Theme.yellowBg,
                     rules: TodayContent.zoneYellow)
        } else {
            ZoneCard(label: "RED (<34%)",
                     color: Theme.red, bg: Theme.redBg,
                     rules: TodayContent.zoneRed)
        }
    }
}

// MARK: - StatGrid

struct StatGrid: View {
    let stats: [StatBox]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                  spacing: 8) {
            ForEach(stats) { s in
                VStack(spacing: 4) {
                    Text(s.value)
                        .font(Typography.statValue)
                        .foregroundStyle(Theme.accent)
                    Text(s.label)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Theme.surface2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
