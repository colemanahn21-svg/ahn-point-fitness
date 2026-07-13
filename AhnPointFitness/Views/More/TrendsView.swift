import SwiftUI
import SwiftData
import Charts

/// Weekly training volume + WHOOP context. Owns its own @Query (same
/// pattern as ExerciseProgressView) so it stays reactive while open.
struct TrendsView: View {
    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var allLogs: [WorkoutLog]

    private var weekPoints: [TrendsModel.WeekPoint] {
        TrendsModel.weeklyTonnage(logs: allLogs)
    }

    private static let weekLabel: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/New_York")!
        f.dateFormat = "M/d"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Weekly Volume")
            Card {
                if weekPoints.isEmpty {
                    Text("No logged sets yet. Volume shows up here once you save workouts with weight and reps.")
                        .font(Typography.body)
                        .foregroundStyle(Theme.text3)
                } else {
                    volumeChart
                    volumeFooter
                }
            }

            whoopComparison
        }
    }

    // MARK: - Volume chart

    private var volumeChart: some View {
        Chart(weekPoints.suffix(12)) { point in
            BarMark(
                x: .value("Week", Self.weekLabel.string(from: point.weekStart)),
                y: .value("Tonnage", point.tonnage)
            )
            .foregroundStyle(Theme.accent.gradient)
            .cornerRadius(4)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(Theme.border)
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(v >= 1000 ? String(format: "%.0fk", v / 1000) : String(format: "%.0f", v))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.text3)
            }
        }
        .frame(height: 180)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var volumeFooter: some View {
        if let latest = weekPoints.last {
            HStack(spacing: 8) {
                Text("This period")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
                Text("\(Int(latest.tonnage).formatted()) lbs")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.accent)
                if weekPoints.count >= 2 {
                    let prev = weekPoints[weekPoints.count - 2].tonnage
                    let delta = latest.tonnage - prev
                    Text(delta >= 0
                         ? "+\(Int(delta).formatted()) vs last wk"
                         : "\(Int(delta).formatted()) vs last wk")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(delta >= 0 ? Theme.green : Theme.yellow)
                }
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    // MARK: - WHOOP context (current week only — cache holds one snapshot)

    @ViewBuilder
    private var whoopComparison: some View {
        if let snap = WhoopTodayCache.load(),
           let strain = snap.weeklyStrainAvg,
           let currentWeekTonnage = currentWeekTonnage {
            SectionLabel(text: "This Week: Load vs Recovery")
            Card {
                HStack(spacing: 8) {
                    metric(label: "VOLUME", value: "\(Int(currentWeekTonnage).formatted())",
                           sub: "lbs lifted", color: Theme.accent)
                    metric(label: "AVG STRAIN", value: String(format: "%.1f", strain),
                           sub: "WHOOP", color: Theme.yellow)
                    if let rec = snap.weeklyRecoveryAvg {
                        metric(label: "AVG RECOVERY", value: "\(rec)%",
                               sub: "WHOOP", color: rec >= 67 ? Theme.green : (rec >= 34 ? Theme.yellow : Theme.red))
                    }
                }
                Text("High volume on falling recovery is the accumulation signal — check Sleep before adding load.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
                    .padding(.top, 8)
            }
        }
    }

    private var currentWeekTonnage: Double? {
        let weekStart = WhoopTodaySnapshot.currentWeekStartET()
        let points = weekPoints
        return points.last(where: { $0.weekStart == weekStart })?.tonnage
    }

    private func metric(label: String, value: String, sub: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Theme.text3)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(sub)
                .font(.system(size: 10))
                .foregroundStyle(Theme.text3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
