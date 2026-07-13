import XCTest
@testable import AhnPointFitness

final class CycleModelTests: XCTestCase {
    // Monday, March 30 2026, midnight ET — the original programme start.
    private let start = TestSupport.etDate(2026, 3, 30, hour: 0)

    private func model(now: Date) -> CycleModel {
        CycleModel(startDateRaw: start.timeIntervalSince1970, now: now)
    }

    func testUnsetWhenRawIsZero() {
        let cycle = CycleModel(startDateRaw: 0, now: Date())
        XCTAssertEqual(cycle.phase, .unset)
        XCTAssertNil(cycle.currentWeek)
        XCTAssertNil(cycle.rangeString)
    }

    func testUpcomingBeforeStart() {
        let cycle = model(now: TestSupport.etDate(2026, 3, 27))
        XCTAssertEqual(cycle.phase, .upcoming(daysUntil: 3))
    }

    func testWeekOneOnStartDay() {
        XCTAssertEqual(model(now: TestSupport.etDate(2026, 3, 30)).phase, .active(week: 1))
    }

    func testWeekBoundaries() {
        // Sunday of week 1 (Apr 5) is still week 1; Monday Apr 6 is week 2.
        XCTAssertEqual(model(now: TestSupport.etDate(2026, 4, 5)).phase, .active(week: 1))
        XCTAssertEqual(model(now: TestSupport.etDate(2026, 4, 6)).phase, .active(week: 2))
    }

    func testDeloadAndTaperFlags() {
        // Week 4 begins Apr 20; week 8 begins May 18.
        let deload = model(now: TestSupport.etDate(2026, 4, 22))
        XCTAssertTrue(deload.isDeloadWeek)
        XCTAssertFalse(deload.isTaperWeek)

        let taper = model(now: TestSupport.etDate(2026, 5, 20))
        XCTAssertTrue(taper.isTaperWeek)
        XCTAssertFalse(taper.isDeloadWeek)
    }

    func testCompletedAfterEightWeeks() {
        // Sunday May 24 is the last day of week 8; Monday May 25 completes it.
        XCTAssertEqual(model(now: TestSupport.etDate(2026, 5, 24)).phase, .active(week: 8))
        XCTAssertEqual(model(now: TestSupport.etDate(2026, 5, 25)).phase, .completed)
    }

    func testRangeStringMatchesOriginalConvention() {
        // The original programme label was "Mar 30 – May 25, 2026".
        XCTAssertEqual(model(now: start).rangeString, "Mar 30 – May 25, 2026")
        XCTAssertEqual(model(now: start).sixWeekRangeString, "Mar 30 – May 11, 2026")
    }

    func testRangeStringAcrossYears() {
        let dec = TestSupport.etDate(2026, 12, 7, hour: 0)   // Monday
        let cycle = CycleModel(startDateRaw: dec.timeIntervalSince1970, now: dec)
        XCTAssertEqual(cycle.rangeString, "Dec 7, 2026 – Feb 1, 2027")
    }
}
