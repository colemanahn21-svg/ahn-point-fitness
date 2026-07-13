import SwiftUI

/// Compact recovery-zone banner for the Log tab. Reads the cached WHOOP
/// snapshot (written by the Today tab) — no networking of its own.
/// Hidden when there's no cache or the snapshot is older than 24 h.
struct RecoveryBanner: View {
    @State private var snapshot: WhoopTodaySnapshot?

    var body: some View {
        Group {
            if let snap = snapshot, let score = snap.recoveryScore {
                banner(score: score)
            }
        }
        .onAppear {
            let cached = WhoopTodayCache.load()
            if let c = cached, -c.fetchedAt.timeIntervalSinceNow < 24 * 3600 {
                snapshot = cached
            } else {
                snapshot = nil
            }
        }
    }

    @ViewBuilder
    private func banner(score: Int) -> some View {
        // Zone thresholds identical to TodayView.ruleForScore.
        let (color, bg, zone, headline): (Color, Color, String, String) = {
            if score >= 67 {
                return (Theme.green, Theme.greenBg, "GREEN",
                        TodayContent.zoneGreen.first?.body ?? "Train as planned")
            } else if score >= 34 {
                return (Theme.yellow, Theme.yellowBg, "YELLOW",
                        TodayContent.zoneYellow.first?.body ?? "Train, but manage intensity")
            } else {
                return (Theme.red, Theme.redBg, "RED",
                        TodayContent.zoneRed.first?.body ?? "Prioritize recovery")
            }
        }()

        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("RECOVERY \(score)% · \(zone)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(headline)
                .font(.system(size: 11))
                .foregroundStyle(Theme.text2)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
        .padding(.bottom, 12)
    }
}
