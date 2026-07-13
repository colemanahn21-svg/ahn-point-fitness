import XCTest
import SwiftData
@testable import AhnPointFitness

@MainActor
final class ExerciseStatsTests: XCTestCase {
    var container: ModelContainer!
    var ctx: ModelContext!

    override func setUp() async throws {
        container = try TestSupport.makeContainer()
        ctx = container.mainContext
    }

    func testEmptyLogsProducesNoHistory() {
        let stats = ExerciseStats.compute(for: "Barbell Bench Press", from: [])
        XCTAssertFalse(stats.hasHistory)
        XCTAssertNil(stats.pr)
        XCTAssertNil(stats.last)
        XCTAssertFalse(stats.flatTrend)
    }

    func testPRIsHighestWeight() {
        let logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
                ("Barbell Bench Press", 1, 185, 8),
                ("Barbell Bench Press", 2, 195, 5),
            ]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 8), sets: [
                ("Barbell Bench Press", 1, 190, 6),
            ]),
        ]
        let stats = ExerciseStats.compute(for: "Barbell Bench Press", from: logs)
        XCTAssertEqual(stats.pr?.weight, 195)
        XCTAssertEqual(stats.pr?.reps, 5)
        XCTAssertEqual(stats.last?.weight, 190)
        XCTAssertEqual(stats.totalSessions, 2)
    }

    func testRepsBreakWeightTies() {
        let logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
                ("Squat", 1, 225, 5),
            ]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 8), sets: [
                ("Squat", 1, 225, 8),
            ]),
        ]
        let stats = ExerciseStats.compute(for: "Squat", from: logs)
        XCTAssertEqual(stats.pr?.reps, 8, "same weight, more reps should win the PR")
    }

    func testSetsMissingWeightOrRepsAreIgnored() {
        let logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
                ("Row", 1, 135, 10),
                ("Row", 2, 999, nil),   // no reps — must not count
                ("Row", 3, nil, 12),    // no weight — must not count
            ]),
        ]
        let stats = ExerciseStats.compute(for: "Row", from: logs)
        XCTAssertEqual(stats.pr?.weight, 135)
        XCTAssertEqual(stats.sessions.first?.sets.count, 1)
    }

    func testFlatTrendNeedsThreeSessionsAndTwoBelowPR() {
        var logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [("Dead", 1, 315, 5)]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 8), sets: [("Dead", 1, 305, 5)]),
        ]
        // Only 2 sessions — not flat yet.
        XCTAssertFalse(ExerciseStats.compute(for: "Dead", from: logs).flatTrend)

        logs.append(
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 15), sets: [("Dead", 1, 300, 5)])
        )
        // 3 sessions, last two below the 315 PR — flat.
        XCTAssertTrue(ExerciseStats.compute(for: "Dead", from: logs).flatTrend)

        logs.append(
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 22), sets: [("Dead", 1, 315, 6)])
        )
        // Latest session matches PR weight — no longer flat.
        XCTAssertFalse(ExerciseStats.compute(for: "Dead", from: logs).flatTrend)
    }

    func testGainComputedFirstToLastSession() {
        let logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [("OHP", 1, 100, 8)]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 29), sets: [("OHP", 1, 110, 8)]),
        ]
        let stats = ExerciseStats.compute(for: "OHP", from: logs)
        XCTAssertEqual(stats.lbGained, 10)
        XCTAssertEqual(stats.percentGain, 10)
    }
}
