import XCTest
@testable import AhnPointFitness

final class ETCalendarTests: XCTestCase {
    func testCalendarIsEasternWithMondayWeeks() {
        XCTAssertEqual(ET.timeZone.identifier, "America/New_York")
        XCTAssertEqual(ET.calendar.timeZone.identifier, "America/New_York")
        XCTAssertEqual(ET.calendar.firstWeekday, 2)
        XCTAssertEqual(ET.calendar.identifier, .gregorian)
    }

    func testStartOfDayIsETMidnight() {
        // 11:30 PM ET on Jun 1 is Jun 2 in UTC; the ET day is still Jun 1.
        let late = TestSupport.etDate(2026, 6, 1, hour: 23) + 1800
        XCTAssertEqual(ET.startOfDay(late), TestSupport.etDate(2026, 6, 1, hour: 0))
        XCTAssertTrue(ET.isSameDay(late, TestSupport.etDate(2026, 6, 1, hour: 0)))
        XCTAssertFalse(ET.isSameDay(late, TestSupport.etDate(2026, 6, 2, hour: 0)))
    }

    func testWeekStartsMonday() {
        // Sunday Jun 7 2026 belongs to the week of Monday Jun 1.
        XCTAssertEqual(ET.weekStart(TestSupport.etDate(2026, 6, 7, hour: 22)), TestSupport.etDate(2026, 6, 1, hour: 0))
        XCTAssertEqual(ET.weekStart(TestSupport.etDate(2026, 6, 8, hour: 0)), TestSupport.etDate(2026, 6, 8, hour: 0))
        XCTAssertEqual(ET.weekStart(TestSupport.etDate(2026, 6, 3)), TestSupport.etDate(2026, 6, 1, hour: 0))
    }

    /// StretchSchedule.today reads .weekday from the Monday-start calendar;
    /// .weekday numbering (1 = Sunday) does not depend on firstWeekday.
    func testTodayMapsWeekdaysUnchanged() {
        XCTAssertEqual(StretchSchedule.today(TestSupport.etDate(2026, 6, 1)), .mon)
        XCTAssertEqual(StretchSchedule.today(TestSupport.etDate(2026, 6, 6)), .sat)
        XCTAssertEqual(StretchSchedule.today(TestSupport.etDate(2026, 6, 7)), .sun)
        XCTAssertEqual(StretchSchedule.today(TestSupport.etDate(2026, 6, 7, hour: 23) + 3540), .sun)
    }
}
