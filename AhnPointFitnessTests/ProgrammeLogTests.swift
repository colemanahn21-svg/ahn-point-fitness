import XCTest
@testable import AhnPointFitness

/// The programme is the one source of the Log tab's exercises.
final class ProgrammeLogTests: XCTestCase {
    private var allDefs: [(ProgrammeDay, ExerciseDef)] {
        ProgrammeDay.allCases.flatMap { day in Programme.exerciseDefs(for: day).map { (day, $0) } }
            + LiftVariant.allCases.map { (.tue, $0.def) }
    }

    /// A lettered exercise ("A1. ", "B. ", "P2. ") must say whether it is
    /// logged, so a new lift can't silently miss the Log tab.
    func testEveryLetteredExerciseSaysHowItIsLogged() {
        let lettered = allDefs.filter { $0.1.name.range(of: #"^[A-Z][0-9]*\. "#, options: .regularExpression) != nil }
        XCTAssertGreaterThan(lettered.count, 40)
        for (day, def) in lettered {
            XCTAssertNotNil(def.logAs, "\(day) \(def.id) \(def.name): add logAs: .name(...) or .notLogged")
        }
    }

    func testEveryLoggedExerciseHasASetCount() {
        for (day, def) in allDefs {
            guard case .name(let name, let override)? = def.logAs else { continue }
            XCTAssertFalse(name.trimmingCharacters(in: .whitespaces).isEmpty, "\(day) \(def.id)")
            XCTAssertTrue(override != nil || Programme.setCount(fromChips: def.chips) != nil,
                          "\(day) \(def.id): no leading N× chip and no sets: override")
        }
    }

    func testLogNamesAreUniqueWithinADay() {
        for day in LogContent.orderedDays {
            for variant in LiftVariant.allCases {
                let names = Programme.loggable(for: day, variant: variant).map(\.name)
                XCTAssertEqual(names.count, Set(names).count, "\(day) \(variant)")
            }
        }
    }

    func testDaysWithoutLogsOfferNothing() {
        XCTAssertTrue(Programme.loggable(for: .wed).isEmpty)
        XCTAssertTrue(Programme.loggable(for: .sun).isEmpty)
    }

    func testSetCountFromChips() {
        XCTAssertEqual(Programme.setCount(fromChips: ["4×6-8", "3-1-1-0"]), 4)
        XCTAssertEqual(Programme.setCount(fromChips: ["2×40 yd"]), 2)
        XCTAssertEqual(Programme.setCount(fromChips: ["12×5"]), 12)
        XCTAssertNil(Programme.setCount(fromChips: ["15", "2-0-1-0"]))
        XCTAssertNil(Programme.setCount(fromChips: ["10/side"]))
        XCTAssertNil(Programme.setCount(fromChips: []))
    }

    func testExplicitSetOverrideWins() {
        let def = ExerciseDef("x", "A. X", ["4×5"], nil, logAs: .name("X", sets: 2))
        XCTAssertEqual(Programme.loggable(def), LoggableExercise("X", 2))
        XCTAssertNil(Programme.loggable(ExerciseDef("y", "B. Y", ["3×5"], nil, logAs: .notLogged)))
    }

    func testVariantResolve() {
        XCTAssertEqual(LiftVariant.resolve(stored: "Trap Bar Squat"), .trapBar)
        XCTAssertEqual(LiftVariant.resolve(stored: "Barbell Back Squat"), .backSquat)
        XCTAssertEqual(LiftVariant.resolve(stored: ""), .backSquat)
        XCTAssertEqual(LiftVariant.resolve(stored: "junk"), .backSquat)
        XCTAssertEqual(LiftVariant.storageKey, "tueLiftAVariant")
        XCTAssertEqual(LiftVariant.allCases.map(\.rawValue), ["Trap Bar Squat", "Barbell Back Squat"])
    }

    func testVariantCardsShowTheirOwnLift() {
        XCTAssertEqual(LiftVariant.trapBar.def.name, "A. Trap Bar Squat (low handles)")
        XCTAssertEqual(LiftVariant.backSquat.def.name, "A. Barbell Back Squat")
        for v in LiftVariant.allCases { XCTAssertEqual(v.def.id, LiftVariant.slotID) }
    }
}
