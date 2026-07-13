import SwiftUI

/// Tuesday Lift A variant selector (e.g. Trap Bar Squat vs Barbell Back Squat).
struct TueVariantPicker: View {
    let options: [String]
    let active: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LIFT A")
                .font(Typography.setHeader)
                .foregroundStyle(Theme.text3)
                .tracking(0.5)
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            onSelect(option)
                        }
                    } label: {
                        Text(option)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(active == option ? .white : Theme.text2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(active == option ? Theme.accent : Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(active == option ? Theme.accent : Theme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 12)
    }
}
