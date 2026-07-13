import SwiftUI

struct RuleItem: View {
    let segments: [InlineSeg]
    var bulletColor: Color = Theme.accent
    var isLast: Bool = false

    enum InlineSeg {
        case text(String)
        case bold(String)
    }

    init(_ text: String, bulletColor: Color = Theme.accent, isLast: Bool = false) {
        self.segments = [.text(text)]
        self.bulletColor = bulletColor
        self.isLast = isLast
    }

    init(segments: [InlineSeg], bulletColor: Color = Theme.accent, isLast: Bool = false) {
        self.segments = segments
        self.bulletColor = bulletColor
        self.isLast = isLast
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Text("→")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(bulletColor)
                    .frame(minWidth: 16, alignment: .leading)
                segments.reduce(Text("")) { acc, seg in
                    switch seg {
                    case .text(let t):
                        return acc + Text(t).foregroundStyle(Theme.text2)
                    case .bold(let t):
                        return acc + Text(t).fontWeight(.semibold).foregroundStyle(Theme.text2)
                    }
                }
                .font(.system(size: 13))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}

struct BulletLabel: View {
    let bullet: String
    let bulletColor: Color
    let text: String
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Text(bullet)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(bulletColor)
                    .frame(minWidth: 16, alignment: .leading)
                Text(text)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}
