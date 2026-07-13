import SwiftUI

struct WhoopWeeklyCard: View {
    let snapshot: WhoopTodaySnapshot

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("WEEKLY AVERAGES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Theme.text3)
                    Text("·")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3.opacity(0.5))
                    Text(Self.weekRangeLabel())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Theme.text2)
                    Spacer()
                }

                let cols = [GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)]
                LazyVGrid(columns: cols, spacing: 8) {
                    recoveryTile
                    sleepTile
                    hrvTile
                    strainTile
                }
            }
        }
    }

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private static let shortDateET: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = etTZ
        f.dateFormat = "MMM d"
        return f
    }()

    /// "APR 27 – MAY 3" — Monday → Sunday of the current calendar week, ET.
    private static func weekRangeLabel() -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = etTZ
        cal.firstWeekday = 2  // Monday
        let now = Date()
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start,
              let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        let s = shortDateET.string(from: weekStart).uppercased()
        let e = shortDateET.string(from: weekEnd).uppercased()
        return "\(s) – \(e)"
    }

    @ViewBuilder
    private var recoveryTile: some View {
        let score = snapshot.weeklyRecoveryAvg
        let color: Color = score.map {
            $0 >= 67 ? Theme.green : ($0 >= 34 ? Theme.yellow : Theme.red)
        } ?? Theme.text3
        let bg: Color = score.map {
            $0 >= 67 ? Theme.greenBg : ($0 >= 34 ? Theme.yellowBg : Theme.redBg)
        } ?? Theme.surface2
        tile(label: "RECOVERY", value: score.map { "\($0)%" } ?? "—",
             valueColor: color, background: bg)
    }

    @ViewBuilder
    private var sleepTile: some View {
        let value = snapshot.weeklySleepHoursAvg.map { String(format: "%.1fh", $0) } ?? "—"
        tile(label: "SLEEP", value: value,
             valueColor: Theme.accent, background: Theme.surface2)
    }

    @ViewBuilder
    private var hrvTile: some View {
        let value = snapshot.weeklyHrvAvg.map { "\(Int($0.rounded())) ms" } ?? "—"
        tile(label: "HRV", value: value,
             valueColor: Theme.text, background: Theme.surface2)
    }

    @ViewBuilder
    private var strainTile: some View {
        let value = snapshot.weeklyStrainAvg.map { String(format: "%.1f", $0) } ?? "—"
        tile(label: "DAY STRAIN", value: value,
             valueColor: Theme.text, background: Theme.surface2)
    }

    private func tile(
        label: String,
        value: String,
        valueColor: Color,
        background: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Theme.text3)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
