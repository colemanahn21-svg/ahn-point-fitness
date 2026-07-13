import SwiftUI

struct PlanView: View {
    @State private var expandedProg: Set<String> = []
    @AppStorage(CycleModel.storageKey) private var cycleStartRaw: Double = 0

    private var currentWeek: Int? {
        CycleModel(startDateRaw: cycleStartRaw).currentWeek
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Progressive Overload")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(PlanContent.overload.enumerated()), id: \.element.id) { idx, wk in
                        overloadRow(wk,
                                    isCurrent: currentWeek == idx + 1,
                                    isLast: idx == PlanContent.overload.count - 1)
                    }
                }
            }

            SectionLabel(text: "Ab Circuit Progression (Wk 5–8)")
            progCard(id: "mon", title: "Mon Circuit Upgrade", items: PlanContent.abProgMon)
            progCard(id: "thu", title: "Thu Circuit Upgrade", items: PlanContent.abProgThu)
            progCard(id: "sat", title: "Sat Circuit Upgrade", items: PlanContent.abProgSat)

            SectionLabel(text: "Deload Week (Wk 4)")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(PlanContent.deload.enumerated()), id: \.offset) { idx, r in
                        RuleItem(r, isLast: idx == PlanContent.deload.count - 1)
                    }
                }
            }

            SectionLabel(text: "Taper Week (Wk 8 — Memorial Day)")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(PlanContent.taper.enumerated()), id: \.offset) { idx, r in
                        RuleItem(r, isLast: idx == PlanContent.taper.count - 1)
                    }
                }
            }

            SectionLabel(text: "Expected Timeline")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(PlanContent.timeline.enumerated()), id: \.offset) { idx, t in
                        BulletLabel(bullet: t.week, bulletColor: t.color, text: t.body,
                                    isLast: idx == PlanContent.timeline.count - 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func overloadRow(_ wk: OverloadWeek, isCurrent: Bool, isLast: Bool) -> some View {
        let bgColor: Color = {
            switch wk.highlight {
            case .none: return .clear
            case .deload: return Theme.accentBg
            case .taper: return Theme.greenBg
            }
        }()
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Text(wk.wk)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(isCurrent ? Theme.green : Theme.accent)
                    .frame(width: 36, alignment: .leading)
                (Text(wk.desc.bold.map { "\($0)" } ?? "").fontWeight(.semibold)
                 + Text(wk.desc.body))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(wk.rpe)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Theme.green)
                    .frame(width: 48, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, (wk.highlight == .none && !isCurrent) ? 0 : 8)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: (wk.highlight == .none && !isCurrent) ? 0 : 4))
            .overlay {
                if isCurrent {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Theme.green, lineWidth: 1)
                }
            }
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }

    @ViewBuilder
    private func progCard(id: String, title: String, items: [AbProgItem]) -> some View {
        let isOpen = expandedProg.contains(id)
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    if isOpen { expandedProg.remove(id) } else { expandedProg.insert(id) }
                }
            } label: {
                HStack {
                    Text(title)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.slot)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                            (Text(item.before + " → ").foregroundStyle(Theme.text2)
                             + Text(item.after).foregroundStyle(Theme.text).fontWeight(.medium))
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        if idx < items.count - 1 {
                            Rectangle().fill(Theme.border).frame(height: 1)
                        }
                    }
                }
                .padding(.top, 14)
            }
        }
        .padding(Theme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .padding(.bottom, 12)
    }
}
