import SwiftUI

enum Theme {
    // Cream + Terracotta — light, warm, welcoming.

    // Surfaces
    static let background = Color(hex: 0xFAF5EE)   // warm cream
    static let surface    = Color(hex: 0xFFFFFF)   // cards
    static let surface2   = Color(hex: 0xF5EDE2)   // inset rows (latte)
    static let surface3   = Color(hex: 0xEDE2D3)   // input fields
    static let border     = Color(hex: 0xE6DACA)

    // Text
    static let text       = Color(hex: 0x352E26)   // espresso
    static let text2      = Color(hex: 0x7A6F60)
    static let text3      = Color(hex: 0xA1937E)

    // Accent
    static let accent     = Color(hex: 0xC65F3C)   // terracotta
    static let accent2    = Color(hex: 0xA84E30)

    // Semantic (darkened for contrast on light surfaces)
    static let green      = Color(hex: 0x2E9E63)
    static let yellow     = Color(hex: 0xC98A06)   // amber
    static let red        = Color(hex: 0xCF4F4B)
    static let orange     = Color(hex: 0xC96F2E)
    static let purple     = Color(hex: 0x7C5FC0)

    // Tinted surfaces used by tag chips and colored rows
    static let accentBg      = Color(hex: 0xC65F3C).opacity(0.10)
    static let accentBgTag   = Color(hex: 0xC65F3C).opacity(0.16)
    static let accentRowBg   = Color(hex: 0xC65F3C).opacity(0.07)
    static let accentRowStroke = Color(hex: 0xC65F3C).opacity(0.18)

    static let greenBg       = Color(hex: 0x2E9E63).opacity(0.12)
    static let greenRowStroke = Color(hex: 0x2E9E63).opacity(0.20)

    static let yellowBg      = Color(hex: 0xC98A06).opacity(0.12)
    static let yellowRowBg   = Color(hex: 0xC98A06).opacity(0.08)

    static let redBg         = Color(hex: 0xCF4F4B).opacity(0.11)

    static let orangeBg      = Color(hex: 0xC96F2E).opacity(0.10)
    static let orangeRowStroke = Color(hex: 0xC96F2E).opacity(0.20)
    static let orangeTagBg   = Color(hex: 0xC96F2E).opacity(0.16)

    static let purpleBg      = Color(hex: 0x7C5FC0).opacity(0.08)
    static let purpleRowStroke = Color(hex: 0x7C5FC0).opacity(0.18)
    static let purpleTagBg   = Color(hex: 0x7C5FC0).opacity(0.14)

    static let stretchRowBg     = Color(hex: 0x8B5E3C).opacity(0.10)
    static let stretchRowStroke = Color(hex: 0x8B5E3C).opacity(0.20)

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
