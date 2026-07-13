import SwiftUI

/// Single-line PR / Last summary, monospace, two states:
///   - Empty:  italic "First time logging — establish a baseline today"
///   - Has history: "PR {w} × {r}  ·  Last {w} × {r}" with green/brown labels
struct PRLineView: View {
    let stats: ExerciseStats

    static let brown = Color(hex: 0x8B5E3C)

    var body: some View {
        Group {
            if let pr = stats.pr, let last = stats.last {
                filledLine(pr: pr, last: last)
            } else {
                Text("First time logging — establish a baseline today")
                    .font(.system(size: 11, design: .monospaced))
                    .italic()
                    .foregroundStyle(Theme.text3)
            }
        }
        .lineSpacing(4)              // ~1.55 line-height for 11pt
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func filledLine(pr: TopSet, last: TopSet) -> some View {
        let prW = formatWeight(pr.weight)
        let prR = pr.reps
        let lastW = formatWeight(last.weight)
        let lastR = last.reps

        let parts =
            Text("PR ").foregroundColor(Theme.green) +
            Text("\(prW) lbs × \(prR)").foregroundColor(Theme.text) +
            Text("  ·  ").foregroundColor(Theme.text3) +
            Text("Last ").foregroundColor(Self.brown) +
            Text("\(lastW) lbs × \(lastR)").foregroundColor(Theme.text)

        return parts
            .font(.system(size: 11, design: .monospaced))
    }

    private func formatWeight(_ w: Double) -> String {
        if w.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(w))
        } else {
            return String(w)
        }
    }
}
