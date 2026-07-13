import SwiftUI

struct SetInputRow: View {
    let setNumber: Int
    @Binding var weight: String
    @Binding var reps: String

    var body: some View {
        HStack(spacing: 8) {
            Text("S\(setNumber)")
                .font(Typography.setLabel)
                .foregroundStyle(Theme.accent)
                .frame(minWidth: 28, alignment: .leading)
            TrackerField(text: $weight, placeholder: "lbs", isDecimal: true)
            Text("lb")
                .font(Typography.sub)
                .foregroundStyle(Theme.text3)
                .frame(minWidth: 24, alignment: .leading)
            TrackerField(text: $reps, placeholder: "reps", isDecimal: false)
            Text("reps")
                .font(Typography.sub)
                .foregroundStyle(Theme.text3)
                .frame(minWidth: 30, alignment: .leading)
        }
    }
}

private struct TrackerField: View {
    @Binding var text: String
    let placeholder: String
    let isDecimal: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundStyle(Theme.text)
            .multilineTextAlignment(.center)
            .keyboardType(isDecimal ? .decimalPad : .numberPad)
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .frame(width: 72)
            .background(Theme.surface3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.border, lineWidth: 1)
            )
    }
}
