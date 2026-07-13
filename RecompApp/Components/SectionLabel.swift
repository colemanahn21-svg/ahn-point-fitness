import SwiftUI

struct SectionLabel: View {
    let text: String
    var color: Color = Theme.text3
    var body: some View {
        Text(text.uppercased())
            .font(Typography.sectionLabel)
            .foregroundStyle(color)
            .tracking(1)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
}

struct SectionDivider: View {
    let text: String
    var color: Color = Theme.text2
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}

struct GroupLabel: View {
    let text: String
    var color: Color = Theme.text2
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .tracking(0.6)
            .padding(.leading, 2)
            .padding(.bottom, 8)
    }
}
