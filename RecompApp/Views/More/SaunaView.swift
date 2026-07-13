import SwiftUI

struct SaunaView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Card {
                VStack(spacing: 10) {
                    ForEach(Array(TodayContent.sauna.enumerated()), id: \.element.id) { idx, entry in
                        saunaRow(entry, isLast: idx == TodayContent.sauna.count - 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func saunaRow(_ entry: SaunaEntry, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(entry.short)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(shortColor(entry.kind))
                .frame(minWidth: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(entry.kind == .skip ? Theme.text3 : Theme.text)
                Text(entry.body)
                    .font(Typography.bodySm)
                    .foregroundStyle(entry.kind == .skip ? Theme.text3 : Theme.text2)
                    .lineSpacing(3)
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }

    private func shortColor(_ kind: SaunaEntry.Kind) -> Color {
        switch kind {
        case .tue: return Theme.accent
        case .wed: return Theme.green
        case .sat: return Theme.orange
        case .skip: return Theme.text3
        }
    }
}
