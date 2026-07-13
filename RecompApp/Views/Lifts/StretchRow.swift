import SwiftUI

struct StretchRow: View {
    let stretch: StretchDef
    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                expanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(stretch.name)
                    .font(Typography.exerciseName)
                    .foregroundStyle(Theme.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !stretch.chips.isEmpty {
                    FlowChips(chips: stretch.chips)
                }
                if expanded {
                    Text(stretch.rationale)
                        .font(Typography.bodySm)
                        .italic()
                        .foregroundStyle(Theme.text3)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, Theme.rowPaddingH)
            .padding(.vertical, Theme.rowPaddingV)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.stretchRowBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.rowRadius)
                    .stroke(Theme.stretchRowStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 6)
    }
}
