import SwiftUI

struct Chip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Typography.chip)
            .foregroundStyle(Theme.text2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Theme.surface3)
            .clipShape(RoundedRectangle(cornerRadius: Theme.chipRadius))
    }
}

struct ChipRow: View {
    let chips: [String]
    var body: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { Chip(text: $0) }
        }
    }
}
