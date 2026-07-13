import SwiftUI

struct InfoBlock: View {
    let title: String?
    let paragraphs: [InfoParagraph]
    var leftBorder: Color? = nil
    var tintedText: Color? = nil

    init(title: String? = nil,
         paragraphs: [InfoParagraph],
         leftBorder: Color? = nil,
         tintedText: Color? = nil) {
        self.title = title
        self.paragraphs = paragraphs
        self.leftBorder = leftBorder
        self.tintedText = tintedText
    }

    init(title: String? = nil,
         text: String,
         leftBorder: Color? = nil,
         tintedText: Color? = nil) {
        self.title = title
        self.paragraphs = [.plain(text)]
        self.leftBorder = leftBorder
        self.tintedText = tintedText
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let border = leftBorder {
                Rectangle().fill(border).frame(width: 3)
            }
            VStack(alignment: .leading, spacing: 8) {
                if let title = title {
                    Text(title)
                        .font(Typography.infoTitle)
                        .foregroundStyle(Theme.accent)
                }
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, p in
                    p.view(tintedText: tintedText)
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
        .padding(.bottom, 10)
    }
}

struct InfoParagraph {
    let segments: [InlineSeg]

    static func plain(_ t: String) -> InfoParagraph {
        .init(segments: [.text(t)])
    }

    enum InlineSeg {
        case text(String)
        case bold(String)
    }

    @ViewBuilder
    func view(tintedText: Color?) -> some View {
        let baseColor = tintedText ?? Theme.text2
        segments.reduce(Text("")) { acc, seg in
            switch seg {
            case .text(let t):
                return acc + Text(t).foregroundStyle(baseColor)
            case .bold(let t):
                return acc + Text(t).fontWeight(.semibold).foregroundStyle(Theme.text)
            }
        }
        .font(Typography.body)
        .lineSpacing(4)
    }
}
