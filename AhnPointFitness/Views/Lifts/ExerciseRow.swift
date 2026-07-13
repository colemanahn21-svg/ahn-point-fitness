import SwiftUI

struct ExerciseRow: View {
    let exercise: ExerciseDef
    @State private var expanded = false
    @AppStorage("tueLiftAVariant") private var tueLiftAVariant: String = "Barbell Back Squat"

    private static let tueLiftAOptions = ["Trap Bar Squat", "Barbell Back Squat"]

    // Substitute the active variant's ExerciseDef when this row is the
    // Tuesday Lift A slot. Keeps the Lifts plan and Log tab synchronised.
    private var displayedExercise: ExerciseDef {
        guard exercise.id == "tue-a" else { return exercise }
        let key = Self.tueLiftAOptions.contains(tueLiftAVariant) ? tueLiftAVariant : "Barbell Back Squat"
        return Programme.tueLiftAVariants[key] ?? exercise
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if exercise.id == "tue-a" {
                tueLiftAVariantToggle
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    expanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(displayedExercise.name)
                        .font(Typography.exerciseName)
                        .foregroundStyle(Theme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !displayedExercise.chips.isEmpty {
                        FlowChips(chips: displayedExercise.chips)
                    }
                    if expanded, let why = displayedExercise.rationale {
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
                .background(Theme.surface2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var tueLiftAVariantToggle: some View {
        HStack(spacing: 6) {
            ForEach(Self.tueLiftAOptions, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        tueLiftAVariant = option
                    }
                } label: {
                    Text(option)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(tueLiftAVariant == option ? .white : Theme.text2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(tueLiftAVariant == option ? Theme.accent : Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tueLiftAVariant == option ? Theme.accent : Theme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 2)
    }
}

struct FlowChips: View {
    let chips: [String]

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(chips, id: \.self) { Chip(text: $0) }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0
        var totalW: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxW && x > 0 {
                y += rowH + spacing
                x = 0
                rowH = 0
            }
            x += size.width + spacing
            rowH = max(rowH, size.height)
            totalW = max(totalW, x)
        }
        return CGSize(width: min(totalW, maxW), height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowH: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowH + spacing
                x = bounds.minX
                rowH = 0
            }
            sub.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowH = max(rowH, size.height)
        }
    }
}
