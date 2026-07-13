import SwiftUI

enum TagKind {
    case cardio, abs, rest, athletic

    var text: String {
        switch self {
        case .cardio: return "CARDIO"
        case .abs: return "ABS"
        case .rest: return "REST"
        case .athletic: return "ATHLETIC"
        }
    }

    var fg: Color {
        switch self {
        case .cardio: return Theme.green
        case .abs: return Theme.accent
        case .rest: return Theme.purple
        case .athletic: return Theme.orange
        }
    }

    var bg: Color {
        switch self {
        case .cardio: return Theme.greenBg
        case .abs: return Theme.accentBgTag
        case .rest: return Theme.purpleTagBg
        case .athletic: return Theme.orangeTagBg
        }
    }
}

struct TagPill: View {
    let kind: TagKind
    var body: some View {
        Text(kind.text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(kind.fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(kind.bg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.tagRadius))
    }
}
