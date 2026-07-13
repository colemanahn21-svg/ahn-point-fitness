import XCTest
import SwiftData
@testable import AhnPointFitness

@MainActor
final class TrendsModelTests: XCTestCase {
    var container: ModelContainer!
    var ctx: ModelContext!

    override func setUp() async throws {
        container = try TestSupport.makeContainer()
        ctx = container.mainContext
    }

    func testEmptyLogsGiveNoPoints() {
        XCTAssertTrue(TrendsModel.weeklyTonnage(logs: []).isEmpty)
    }

    func testTonnageSumsWeightTimesReps() {
        let log = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
            ("Bench", 1, 100, 10),   // 1000
            ("Bench", 2, 100, 8),    // 800
            ("Row", 1, 50, 10),      // 500
        ])
        let points = TrendsModel.weeklyTonnage(logs: [log])
        XCTAssertEqual(points.count, 1)
        XCTAssertEqual(points.first?.tonnage, 2300)
    }

    func testIncompleteSetsContributeNothing() {
        let log = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
            ("Bench", 1, 100, 10),
            ("Bench", 2, 500, nil),
            ("Bench", 3, nil, 10),
        ])
        XCTAssertEqual(TrendsModel.weeklyTonnage(logs: [log]).first?.tonnage, 1000)
    }

    func testGroupsByETCalendarWeek() {
        // Mon Jun 1 and Sun Jun 7 2026 share a week; Mon Jun 8 starts the next.
        let logs = [
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [("Bench", 1, 100, 10)]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 7), sets: [("Bench", 1, 100, 10)]),
            TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 8), sets: [("Bench", 1, 100, 10)]),
        ]
        let points = TrendsModel.weeklyTonnage(logs: logs)
        XCTAssertEqual(points.count, 2)
        XCTAssertEqual(points.first?.tonnage, 2000)
        XCTAssertEqual(points.last?.tonnage, 1000)
        XCTAssertLessThan(points[0].weekStart, points[1].weekStart)
    }
}
