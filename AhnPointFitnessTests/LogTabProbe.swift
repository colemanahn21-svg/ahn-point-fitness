import Foundation
@testable import AhnPointFitness

/// What the Log tab offers, read the way the views read it. The golden test
/// (`LogTabGoldenTests`) calls only this, so the test file itself never has
/// to change when the code behind the Log tab is reorganised.
enum LogTabProbe {
    /// LogView: the day's exercises, with Tuesday Lift A resolved from the
    /// stored `tueLiftAVariant` AppStorage value.
    static func offered(_ day: ProgrammeDay, storedVariant: String) -> [(String, Int)] {
        Programme.loggable(for: day, variant: LiftVariant.resolve(stored: storedVariant))
            .map { ($0.name, $0.sets) }
    }

    /// EditLogView, DemoSeeder and LogHistoryCard: the day as written,
    /// before any Tuesday variant is applied.
    static func asWritten(_ day: ProgrammeDay) -> [(String, Int)] {
        Programme.loggable(for: day).map { ($0.name, $0.sets) }
    }

    static var days: [ProgrammeDay] { LogContent.orderedDays }
}
