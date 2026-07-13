import SwiftUI

// WhoopTodaySnapshot lives in WhoopTodaySnapshot.swift;
// WhoopTodayCache / WhoopProfileCache live in Services/WhoopCaches.swift.

struct WhoopTodayCard: View {
    @EnvironmentObject private var auth: WhoopAuth
    @ObservedObject var state: WhoopTodayState

    private var snapshot: WhoopTodaySnapshot? { state.snapshot }
    private var isLoading: Bool { state.isLoading }
    private var errorMessage: String? { state.errorMessage }

    var body: some View {
        Card { content }
    }

    // MARK: Content

    @ViewBuilder
    private var content: some View {
        if !auth.isConnected {
            emptyState
        } else {
            connectedContent
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("WHOOP")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(Theme.text3)
            Text("Connect WHOOP in Settings to see your data here")
                .font(.system(size: 13))
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var connectedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("WHOOP TODAY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.text3)
                Text("·")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3.opacity(0.5))
                Text(Self.shortDateET.string(from: Date()).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.text2)
                Spacer()
                Button {
                    Task { await state.refresh(auth: auth) }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.7)
                            .tint(Theme.accent)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.accent)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }

            tileGrid

            footerRow
        }
        .task {
            await state.refreshIfStale(auth: auth)
        }
    }

    private var tileGrid: some View {
        let cols = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return LazyVGrid(columns: cols, spacing: 8) {
            recoveryTile
            sleepTile
            hrvTile
            strainTile
        }
    }

    @ViewBuilder
    private var recoveryTile: some View {
        let score = snapshot?.recoveryScore
        let color: Color = score.map { $0 >= 67 ? Theme.green : ($0 >= 34 ? Theme.yellow : Theme.red) } ?? Theme.text3
        let bg: Color = score.map { $0 >= 67 ? Theme.greenBg : ($0 >= 34 ? Theme.yellowBg : Theme.redBg) } ?? Theme.surface2
        tile(label: "RECOVERY", value: score.map { "\($0)%" } ?? "—", valueColor: color, background: bg)
    }

    @ViewBuilder
    private var sleepTile: some View {
        let perf = snapshot?.sleepPerformance.map { "\($0)%" } ?? "—"
        let hours = snapshot?.sleepHours.map { String(format: "%.1fh", $0) }
        tile(label: "SLEEP", value: perf, sublabel: hours, valueColor: Theme.accent, background: Theme.surface2)
    }

    @ViewBuilder
    private var hrvTile: some View {
        let h = snapshot?.hrvMilli
        let value = h.map { "\(Int($0.rounded())) ms" } ?? "—"
        let delta = snapshot?.hrvDelta
        let arrow: (String, Color)? = delta.map {
            if $0 >= 1   { return ("arrow.up", Theme.green) }
            if $0 <= -1  { return ("arrow.down", Theme.red) }
            return ("arrow.right", Theme.text3)
        }
        tile(
            label: "HRV (vs 30-day)",
            value: value,
            sublabel: delta.flatMap { d in
                let sign = d > 0 ? "+" : ""
                return "\(sign)\(Int(d.rounded())) ms"
            },
            valueColor: Theme.text,
            background: Theme.surface2,
            trailingIcon: arrow
        )
    }

    @ViewBuilder
    private var strainTile: some View {
        let s = snapshot?.dayStrain.map { String(format: "%.1f", $0) } ?? "—"
        tile(label: "DAY STRAIN", value: s, valueColor: Theme.text, background: Theme.surface2)
    }

    private func tile(
        label: String,
        value: String,
        sublabel: String? = nil,
        valueColor: Color,
        background: Color,
        trailingIcon: (String, Color)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Theme.text3)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(valueColor)
                if let icon = trailingIcon {
                    Image(systemName: icon.0)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(icon.1)
                }
            }
            if let sub = sublabel {
                Text(sub)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Theme.text2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var footerRow: some View {
        HStack(spacing: 8) {
            if let s = snapshot {
                Text("Last sync \(Self.formatLastSync(s.fetchedAt))")
                    .font(.system(size: 11))
                    .foregroundStyle(staleColor(s.fetchedAt))
            } else if let err = errorMessage {
                Text(err)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.red)
                    .lineLimit(2)
            } else if isLoading {
                Text("Syncing…")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            } else {
                Text("No data yet")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }
            Spacer()
        }
    }

    // MARK: ET-zoned formatters (used for header label)

    static let shortDateET: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "America/New_York")!
        f.dateFormat = "EEE MMM d"     // e.g., "FRI MAY 1"
        return f
    }()

    // MARK: Formatting

    private static func formatLastSync(_ d: Date) -> String {
        let interval = -d.timeIntervalSinceNow
        if interval < 60 * 60 {
            // Today, recent — show hh:mm a in local time
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: d)
        }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: d, relativeTo: Date())
    }

    private func staleColor(_ d: Date) -> Color {
        let interval = -d.timeIntervalSinceNow
        if interval > 6 * 3600 { return Theme.yellow }
        return Theme.text3
    }
}
