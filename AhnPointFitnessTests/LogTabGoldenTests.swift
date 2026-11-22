import XCTest
@testable import AhnPointFitness

/// Pins the exact exercise names, order and set counts the Log tab offers.
/// Logs are stored by exercise NAME: a changed name here orphans the history
/// already on the phone. Do not edit the expected lists to make a refactor
/// pass; if a name really has to change, that is a data migration.
final class LogTabGoldenTests: XCTestCase {
    private static let mon: [(String, Int)] = [
        ("Barbell Bench Press", 4),
        ("Barbell Bent-Over Row", 4),
        ("Incline DB Press", 3),
        ("Chest-Supported DB Row", 3),
        ("Cable Fly", 3),
        ("Half-Kneeling Cable Chop", 3),
        ("Face Pulls", 3),
    ]
    private static func tue(liftA: String) -> [(String, Int)] {
        [
            (liftA, 4),
            ("Romanian Deadlift", 4),
            ("Walking Lunges (DB)", 3),
            ("Leg Curl", 3),
            ("Leg Press", 3),
            ("Standing Calf Raise", 4),
        ]
    }
    private static let thu: [(String, Int)] = [
        ("Seated DB OHP", 4),
        ("EZ-Bar Curl", 3),
        ("Cable Lateral Raise", 3),
        ("OH Tricep Extension", 3),
        ("Reverse Pec Deck", 3),
        ("Hammer Curl", 3),
        ("Dip Machine / CG Bench", 3),
        ("Incline DB Curl", 3),
    ]
    private static let fri: [(String, Int)] = [
        ("Med Ball Supine Throw", 2),
        ("Explosive Pull-Up", 2),
        ("SA DB Row (staggered)", 3),
        ("SA DB Push Press", 3),
        ("Landmine Row", 3),
        ("Landmine Press (half-kneel)", 3),
        ("Cable Face Pull", 2),
        ("Cable Pallof Press", 2),
        ("Cable Chop", 2),
    ]
    private static let sat: [(String, Int)] = [
        ("Box Jump", 3),
        ("Lateral Bound", 3),
        ("Med Ball Rotational Slam", 3),
        ("Farmer's Carry", 2),
        ("Overhead Carry", 2),
        ("Bear Crawl", 2),
    ]

    private func assertSame(_ actual: [(String, Int)], _ expected: [(String, Int)],
                            _ label: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.map(\.0), expected.map(\.0), "\(label): names/order", file: file, line: line)
        XCTAssertEqual(actual.map(\.1), expected.map(\.1), "\(label): set counts", file: file, line: line)
    }

    func testLogDaysInOrder() {
        XCTAssertEqual(LogTabProbe.days, [.mon, .tue, .thu, .fri, .sat])
    }

    func testMonday() { assertSame(LogTabProbe.offered(.mon, storedVariant: "Barbell Back Squat"), Self.mon, "mon") }
    func testThursday() { assertSame(LogTabProbe.offered(.thu, storedVariant: "Barbell Back Squat"), Self.thu, "thu") }
    func testFriday() { assertSame(LogTabProbe.offered(.fri, storedVariant: "Barbell Back Squat"), Self.fri, "fri") }
    func testSaturday() { assertSame(LogTabProbe.offered(.sat, storedVariant: "Barbell Back Squat"), Self.sat, "sat") }

    func testTuesdayTrapBar() {
        assertSame(LogTabProbe.offered(.tue, storedVariant: "Trap Bar Squat"),
                   Self.tue(liftA: "Trap Bar Squat"), "tue trap bar")
    }

    func testTuesdayBackSquat() {
        assertSame(LogTabProbe.offered(.tue, storedVariant: "Barbell Back Squat"),
                   Self.tue(liftA: "Barbell Back Squat"), "tue back squat")
    }

    func testTuesdayUnknownStoredValueFallsBackToBackSquat() {
        for stored in ["", "Front Squat", "trap bar squat"] {
            assertSame(LogTabProbe.offered(.tue, storedVariant: stored),
                       Self.tue(liftA: "Barbell Back Squat"), "tue stored \(stored)")
        }
    }

    func testVariantOnlyAffectsTuesday() {
        assertSame(LogTabProbe.offered(.mon, storedVariant: "Trap Bar Squat"), Self.mon, "mon trap")
        assertSame(LogTabProbe.offered(.sat, storedVariant: "Trap Bar Squat"), Self.sat, "sat trap")
    }

    /// The editor, demo seeder and history card list the day as written:
    /// Tuesday's Lift A is Trap Bar Squat there whatever the stored variant.
    func testDaysAsWritten() {
        assertSame(LogTabProbe.asWritten(.mon), Self.mon, "mon written")
        assertSame(LogTabProbe.asWritten(.tue), Self.tue(liftA: "Trap Bar Squat"), "tue written")
        assertSame(LogTabProbe.asWritten(.thu), Self.thu, "thu written")
        assertSame(LogTabProbe.asWritten(.fri), Self.fri, "fri written")
        assertSame(LogTabProbe.asWritten(.sat), Self.sat, "sat written")
    }
}
