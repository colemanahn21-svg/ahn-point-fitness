import SwiftUI

enum Typography {
    // Body scales (SF Pro)
    static let pageTitle    = Font.system(size: 18, weight: .bold)
    static let sectionLabel = Font.system(size: 12, weight: .bold)
    static let cardTitle    = Font.system(size: 15, weight: .semibold)
    static let cardSubtitle = Font.system(size: 12, weight: .regular)
    static let exerciseName = Font.system(size: 14, weight: .semibold)
    static let exerciseNameSm = Font.system(size: 13, weight: .semibold)
    static let bodySm       = Font.system(size: 12, weight: .regular)
    static let body         = Font.system(size: 13, weight: .regular)
    static let bodyMd       = Font.system(size: 14, weight: .regular)
    static let infoTitle    = Font.system(size: 13, weight: .bold)
    static let sub          = Font.system(size: 12, weight: .regular)

    // Mono (SF Mono)
    static let chip         = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let statValue    = Font.system(size: 18, weight: .bold, design: .monospaced)
    static let dataMono     = Font.system(size: 13, weight: .regular, design: .monospaced)
    static let dataMonoSm   = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let mealTime     = Font.system(size: 12, weight: .medium, design: .monospaced)
    static let suppTime     = Font.system(size: 11, weight: .regular, design: .monospaced)
    static let historyMono  = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let setLabel     = Font.system(size: 12, weight: .bold, design: .monospaced)
    static let setHeader    = Font.system(size: 10, weight: .semibold)
}
