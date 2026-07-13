import SwiftUI

struct ZoneCard: View {
    let label: String
    let color: Color
    let bg: Color
    let rules: [ZoneRule]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("● " + label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
                .padding(.bottom, 8)
            ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                (Text(rule.label + ": ").fontWeight(.semibold).foregroundStyle(Theme.text)
                 + Text(rule.body).foregroundStyle(Theme.text))
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .padding(.bottom, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .padding(.bottom, 10)
    }
}

struct ZoneRule {
    let label: String
    let body: String
}
