import SwiftUI

struct CardioRow: View {
    let item: CardioDef
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.name)
                .font(Typography.exerciseName)
                .foregroundStyle(Theme.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            if !item.chips.isEmpty { FlowChips(chips: item.chips) }
        }
        .padding(.horizontal, Theme.rowPaddingH)
        .padding(.vertical, Theme.rowPaddingV)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.greenBg)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.rowRadius)
                .stroke(Theme.greenRowStroke, lineWidth: 1)
        )
        .padding(.bottom, 6)
    }
}

struct AbRow: View {
    let exercise: ExerciseDef
    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                expanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(Typography.exerciseName)
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !exercise.chips.isEmpty {
                    FlowChips(chips: exercise.chips)
                }
                if expanded, let why = exercise.rationale {
                    Text(why)
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
            .background(Theme.accentRowBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.rowRadius)
                    .stroke(Theme.accentRowStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 6)
    }
}
