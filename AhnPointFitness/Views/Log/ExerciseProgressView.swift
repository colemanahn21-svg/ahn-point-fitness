import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    let exerciseName: String

    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var allLogs: [WorkoutLog]

    private var stats: ExerciseStats {
        ExerciseStats.compute(for: exerciseName, from: allLogs)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    let s = stats
                    VStack(alignment: .leading, spacing: 14) {
                        PRCard(stats: s)

                        if s.hasMultipleSessions {
                            ChartCard(stats: s)
                        } else if s.hasHistory {
                            ChartPlaceholderCard()
                        }

                        if s.hasHistory {
                            HistoryCard(stats: s)
                        }
                    }
                    .padding(.horizontal, Theme.pagePaddingH)
                    .padding(.top, Theme.pagePaddingV)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - PR card

private struct PRCard: View {
    let stats: ExerciseStats

    var body: some View {
        if let pr = stats.pr {
            filledCard(pr: pr)
        } else {
            emptyCard
        }
    }

    @ViewBuilder
    private func filledCard(pr: TopSet) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🏆 PERSONAL RECORD")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.green)
            Text("\(formatWeight(pr.weight)) lb × \(pr.reps)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.text)
            Text(prDateFormatter.string(from: pr.date))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Theme.text3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [PRLineView.brown.opacity(0.22), Theme.green.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NO HISTORY YET")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text2)
            Text("First time logging")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.text)
            Text("Save a set on the Log tab to establish your baseline.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.text2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}

// MARK: - Chart card

private struct ChartCard: View {
    let stats: ExerciseStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOP SET OVER TIME")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text3)

            chart
                .frame(height: 180)

            Rectangle().fill(Theme.border).frame(height: 1).padding(.top, 4)

            statsRow
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    // Chart

    @ViewBuilder
    private var chart: some View {
        Chart {
            ForEach(stats.sessions) { s in
                AreaMark(
                    x: .value("Date", s.date),
                    y: .value("Weight", s.topSet.weight)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(PRLineView.brown.opacity(0.10))

                LineMark(
                    x: .value("Date", s.date),
                    y: .value("Weight", s.topSet.weight)
                )
                .interpolationMethod(.linear)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(PRLineView.brown)

                PointMark(
                    x: .value("Date", s.date),
                    y: .value("Weight", s.topSet.weight)
                )
                .symbolSize(s.id == stats.prSessionLogID ? 60 : 30)
                .foregroundStyle(s.id == stats.prSessionLogID ? Theme.green : PRLineView.brown)
            }
        }
        .chartYScale(domain: yScale)
        .chartXAxis {
            AxisMarks(values: tickDates) { _ in
                AxisGridLine().foregroundStyle(Theme.border)
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(Theme.text3)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(Theme.border)
                AxisValueLabel().foregroundStyle(Theme.text3)
            }
        }
    }

    // Stats row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statBox(label: "CHANGE", value: changeStr, color: changeColor)
            statBox(label: "SESSIONS", value: "\(stats.totalSessions)", color: Theme.text)
            statBox(label: "OVERALL", value: percentStr, color: Theme.text)
        }
    }

    private func statBox(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text3)
        }
        .frame(maxWidth: .infinity)
    }

    private var changeStr: String {
        if stats.flatTrend { return "flat 2wk" }
        if stats.lbGained == 0 { return "—" }
        let sign = stats.lbGained > 0 ? "+" : ""
        return "\(sign)\(formatWeight(stats.lbGained)) lb"
    }

    private var changeColor: Color {
        stats.flatTrend ? Theme.yellow : Theme.text
    }

    private var percentStr: String {
        let p = stats.percentGain
        if p == 0 { return "0%" }
        let sign = p > 0 ? "+" : ""
        return "\(sign)\(p)%"
    }

    // Axis helpers

    private var tickDates: [Date] {
        let dates = stats.sessions.map(\.date)
        guard let first = dates.first, let last = dates.last, dates.count >= 2 else {
            return dates
        }
        let span = last.timeIntervalSince(first)
        let m1 = first.addingTimeInterval(span / 3)
        let m2 = first.addingTimeInterval(span * 2 / 3)
        return [first, m1, m2, last]
    }

    private var yScale: ClosedRange<Double> {
        let weights = stats.sessions.map(\.topSet.weight)
        guard let lo = weights.min(), let hi = weights.max() else { return 0...100 }
        let range = hi - lo
        let pad = max(range * 0.2, 5)
        let yMin = max(0, ((lo - pad) / 5).rounded(.down) * 5)
        let yMax = ((hi + pad) / 5).rounded(.up) * 5
        return yMin...yMax
    }
}

// MARK: - Chart placeholder (single session)

private struct ChartPlaceholderCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOP SET OVER TIME")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text3)
            Text("Chart will appear after your second logged session")
                .font(.system(size: 13))
                .foregroundStyle(Theme.text3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}

// MARK: - Session history

private struct HistoryCard: View {
    let stats: ExerciseStats

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SESSION HISTORY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text3)
                .padding(.bottom, 8)

            ForEach(Array(stats.sessions.reversed().enumerated()), id: \.element.id) { _, session in
                SessionHistoryRow(
                    session: session,
                    isPRSession: session.id == stats.prSessionLogID
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}

private struct SessionHistoryRow: View {
    let session: SessionData
    let isPRSession: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(historyDateFormatter.string(from: session.date))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.accent)
                if isPRSession {
                    Text("🏆 PR")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Theme.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.green.opacity(0.15))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            setsText
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Theme.text2)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.text3.opacity(0.3)).frame(height: 1)
        }
    }

    private var setsText: Text {
        var result = Text("")
        for (idx, s) in session.sets.enumerated() {
            let isTop =
                s.weight == session.topSet.weight &&
                s.reps == session.topSet.reps &&
                s.setNumber == session.topSet.setNumber
            let str = "\(formatWeight(s.weight))lb×\(s.reps)"
            let seg: Text = isTop
                ? Text(str).bold().foregroundColor(Theme.text)
                : Text(str)
            if idx == 0 {
                result = seg
            } else {
                let sep = Text("  ·  ").foregroundColor(Theme.text3)
                result = result + sep + seg
            }
        }
        return result
    }
}

// MARK: - Helpers
// formatWeight lives in Resources/ETCalendar.swift.

private let etTZ = TimeZone(identifier: "America/New_York")!

private let prDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.timeZone = etTZ
    f.dateFormat = "MMM d, yyyy"
    return f
}()

private let historyDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.timeZone = etTZ
    f.dateFormat = "MMM d"
    return f
}()
