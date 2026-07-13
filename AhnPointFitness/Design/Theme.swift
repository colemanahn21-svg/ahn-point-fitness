import SwiftUI

enum Theme {
    // Surfaces
    static let background = Color(hex: 0x0A0E17)
    static let surface    = Color(hex: 0x131925)
    static let surface2   = Color(hex: 0x1A2235)
    static let surface3   = Color(hex: 0x212B40)
    static let border     = Color(hex: 0x2A3552)

    // Text
    static let text       = Color(hex: 0xE8ECF4)
    static let text2      = Color(hex: 0x8B95AA)
    static let text3      = Color(hex: 0x5A6478)

    // Accent
    static let accent     = Color(hex: 0x4E8CFF)
    static let accent2    = Color(hex: 0x3A6FD8)

    // Semantic
    static let green      = Color(hex: 0x34D399)
    static let yellow     = Color(hex: 0xFBBF24)
    static let red        = Color(hex: 0xF87171)
    static let orange     = Color(hex: 0xFB923C)
    static let purple     = Color(hex: 0xA78BFA)

    // Tinted surfaces used by tag chips and colored rows
    static let accentBg      = Color(hex: 0x4E8CFF).opacity(0.08)
    static let accentBgTag   = Color(hex: 0x4E8CFF).opacity(0.15)
    static let accentRowBg   = Color(hex: 0x4E8CFF).opacity(0.06)
    static let accentRowStroke = Color(hex: 0x4E8CFF).opacity(0.12)

    static let greenBg       = Color(hex: 0x34D399).opacity(0.10)
    static let greenRowStroke = Color(hex: 0x34D399).opacity(0.12)

    static let yellowBg      = Color(hex: 0xFBBF24).opacity(0.10)
    static let yellowRowBg   = Color(hex: 0xFBBF24).opacity(0.06)

    static let redBg         = Color(hex: 0xF87171).opacity(0.10)

    static let orangeBg      = Color(hex: 0xFB923C).opacity(0.08)
    static let orangeRowStroke = Color(hex: 0xFB923C).opacity(0.15)
    static let orangeTagBg   = Color(hex: 0xFB923C).opacity(0.15)

    static let purpleBg      = Color(hex: 0xA78BFA).opacity(0.06)
    static let purpleRowStroke = Color(hex: 0xA78BFA).opacity(0.12)
    static let purpleTagBg   = Color(hex: 0xA78BFA).opacity(0.12)

    static let stretchRowBg     = Color(hex: 0x8B5E3C).opacity(0.08)
    static let stretchRowStroke = Color(hex: 0x8B5E3C).opacity(0.15)

    // Radii
    static let cardRadius: CGFloat = 16
    static let rowRadius: CGFloat  = 12
    static let chipRadius: CGFloat = 6
    static let tagRadius: CGFloat  = 8

    // Spacing
    static let pagePaddingH: CGFloat   = 16
    static let pagePaddingV: CGFloat   = 16
    static let cardPadding: CGFloat    = 16
    static let rowPaddingH: CGFloat    = 14
    static let rowPaddingV: CGFloat    = 12
    static let sectionSpacing: CGFloat = 20
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
