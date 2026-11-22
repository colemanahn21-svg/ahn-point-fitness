import XCTest
import SwiftData
@testable import AhnPointFitness

@MainActor
final class WorkoutLogStoreTests: XCTestCase {
    var container: ModelContainer!
    var ctx: ModelContext!

    override func setUp() async throws {
        container = try TestSupport.makeContainer()
        ctx = container.mainContext
    }

    private struct Boom: LocalizedError { var errorDescription: String? { "disk full" } }

    private func sets(_ log: WorkoutLog, _ name: String) -> [(Int, Double?, Int?)] {
        log.sets.filter { $0.exerciseName == name }
            .sorted { $0.setNumber < $1.setNumber }
            .map { ($0.setNumber, $0.weight, $0.reps) }
    }

    private func allLogs() throws -> [WorkoutLog] {
        try ctx.fetch(FetchDescriptor<WorkoutLog>())
    }

    // MARK: New log

    func testSaveCreatesLogAtETMidnight() throws {
        var sheet = SetSheet()
        sheet["Barbell Bench Press", .weight, 1] = "185"
        sheet["Barbell Bench Press", .reps, 1] = "8"
        sheet["Barbell Bench Press", .weight, 2] = "190"
        sheet["Barbell Bench Press", .reps, 2] = "6"

        let now = TestSupport.etDate(2026, 6, 1, hour: 23)
        let log = try WorkoutLogStore.save(
            sheet, exercises: [LoggableExercise("Barbell Bench Press", 4)],
            day: .mon, date: now, existing: nil, in: ctx)

        XCTAssertEqual(log.day, "mon")
        XCTAssertEqual(log.date, TestSupport.etDate(2026, 6, 1, hour: 0))
        XCTAssertEqual(try allLogs().count, 1)
        let s = sets(log, "Barbell Bench Press")
        XCTAssertEqual(s.map(\.0), [1, 2])
        XCTAssertEqual(s.map(\.1), [185, 190])
        XCTAssertEqual(s.map(\.2), [8, 6])
    }

    func testEmptyAndBlankRowsAreSkipped() throws {
        var sheet = SetSheet()
        sheet["Leg Curl", .weight, 1] = "100"
        sheet["Leg Curl", .weight, 2] = "   "
        sheet["Leg Curl", .reps, 2] = ""
        sheet["Leg Curl", .reps, 3] = "12"   // reps only: kept, weight nil

        let log = try WorkoutLogStore.save(
            sheet, exercises: [LoggableExercise("Leg Curl", 3), LoggableExercise("Leg Press", 3)],
            day: .tue, date: TestSupport.etDate(2026, 6, 2), existing: nil, in: ctx)

        let s = sets(log, "Leg Curl")
        XCTAssertEqual(s.map(\.0), [1, 3])
        XCTAssertEqual(s[0].1, 100); XCTAssertNil(s[0].2)
        XCTAssertNil(s[1].1); XCTAssertEqual(s[1].2, 12)
        XCTAssertTrue(sets(log, "Leg Press").isEmpty)
    }

    // MARK: Editing

    func testEditingKeepsTheOtherVariantsSets() throws {
        let day = TestSupport.etDate(2026, 6, 2, hour: 0)
        let existing = TestSupport.makeLog(in: ctx, date: day, day: "tue", sets: [
            ("Trap Bar Squat", 1, 315, 5),
            ("Trap Bar Squat", 2, 315, 5),
            ("Romanian Deadlift", 1, 225, 8),
        ])
        try ctx.save()

        var sheet = SetSheet(log: existing)
        sheet["Barbell Back Squat", .weight, 1] = "275"
        sheet["Barbell Back Squat", .reps, 1] = "6"
        sheet["Romanian Deadlift", .weight, 1] = "235"

        let exercises = Programme.loggable(for: .tue, variant: .backSquat)
        XCTAssertEqual(exercises.first?.name, "Barbell Back Squat")
        let found = WorkoutLogStore.log(for: .tue, on: TestSupport.etDate(2026, 6, 2, hour: 18), in: try allLogs())
        XCTAssertTrue(found === existing)

        let log = try WorkoutLogStore.save(
            sheet, exercises: exercises, day: .tue,
            date: TestSupport.etDate(2026, 6, 2, hour: 18), existing: found, in: ctx)

        XCTAssertTrue(log === existing)
        XCTAssertEqual(try allLogs().count, 1)
        XCTAssertEqual(log.date, day, "an edited log keeps its date")
        XCTAssertEqual(sets(log, "Trap Bar Squat").map(\.1), [315, 315])
        XCTAssertEqual(sets(log, "Barbell Back Squat").map(\.1), [275])
        XCTAssertEqual(sets(log, "Romanian Deadlift").map(\.1), [235])
        XCTAssertEqual(sets(log, "Romanian Deadlift").map(\.2), [8])
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<SetEntry>()).count, 4, "replaced sets are deleted, not orphaned")
    }

    func testClearingAVisibleExerciseRemovesItsSets() throws {
        let existing = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1, hour: 0), sets: [
            ("Face Pulls", 1, 40, 15),
        ])
        try ctx.save()
        var sheet = SetSheet(log: existing)
        sheet["Face Pulls", .weight, 1] = ""
        sheet["Face Pulls", .reps, 1] = ""
        let log = try WorkoutLogStore.save(
            sheet, exercises: [LoggableExercise("Face Pulls", 3)], day: .mon,
            date: existing.date, existing: existing, in: ctx)
        XCTAssertTrue(log.sets.isEmpty)
    }

    func testSheetLoadsFromLog() {
        let log = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1), sets: [
            ("Cable Fly", 2, 32.5, 12), ("Cable Fly", 1, 30, nil),
        ])
        let sheet = SetSheet(log: log)
        XCTAssertEqual(sheet["Cable Fly", .weight, 1], "30")
        XCTAssertEqual(sheet["Cable Fly", .reps, 1], "")
        XCTAssertEqual(sheet["Cable Fly", .weight, 2], "32.5")
        XCTAssertEqual(sheet["Cable Fly", .reps, 2], "12")
        XCTAssertEqual(SetSheet(log: nil), SetSheet())
    }

    // MARK: ET day boundary

    func testFindsTodaysLogByETDayNotUTC() throws {
        // 11:30 PM ET on Jun 1 is already Jun 2 in UTC.
        let log = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1, hour: 0), sets: [])
        let logs = [log]
        XCTAssertTrue(WorkoutLogStore.log(for: .mon, on: TestSupport.etDate(2026, 6, 1, hour: 23) + 1800, in: logs) === log)
        XCTAssertTrue(WorkoutLogStore.log(for: .mon, on: TestSupport.etDate(2026, 6, 1, hour: 0), in: logs) === log)
        XCTAssertNil(WorkoutLogStore.log(for: .mon, on: TestSupport.etDate(2026, 6, 2, hour: 0) + 60, in: logs))
        XCTAssertNil(WorkoutLogStore.log(for: .mon, on: TestSupport.etDate(2026, 5, 31, hour: 23) + 3540, in: logs))
        XCTAssertNil(WorkoutLogStore.log(for: .tue, on: TestSupport.etDate(2026, 6, 1), in: logs), "day name must match")
    }

    func testSaveJustAfterETMidnightStartsANewDay() throws {
        let night = TestSupport.etDate(2026, 6, 1, hour: 23) + 3540  // 11:59 PM ET
        var sheet = SetSheet()
        sheet["Face Pulls", .reps, 1] = "15"
        let first = try WorkoutLogStore.save(sheet, exercises: [LoggableExercise("Face Pulls", 3)],
                                             day: .mon, date: night, existing: nil, in: ctx)
        XCTAssertEqual(first.date, TestSupport.etDate(2026, 6, 1, hour: 0))

        let morning = TestSupport.etDate(2026, 6, 2, hour: 0) + 60    // 12:01 AM ET
        XCTAssertNil(WorkoutLogStore.log(for: .mon, on: morning, in: try allLogs()))
        let second = try WorkoutLogStore.save(sheet, exercises: [LoggableExercise("Face Pulls", 3)],
                                              day: .mon, date: morning, existing: nil, in: ctx)
        XCTAssertEqual(second.date, TestSupport.etDate(2026, 6, 2, hour: 0))
        XCTAssertEqual(try allLogs().count, 2)
    }

    // MARK: Bug fixes

    func testWeightAndRepsWithSpacesAndDecimalCommaParse() throws {
        var sheet = SetSheet()
        sheet["Cable Fly", .weight, 1] = " 135 "
        sheet["Cable Fly", .reps, 1] = " 8 "
        sheet["Cable Fly", .weight, 2] = "135,5"
        sheet["Cable Fly", .reps, 2] = "10\n"
        sheet["Cable Fly", .weight, 3] = "\t 42.5"
        sheet["Cable Fly", .reps, 3] = "12"
        let log = try WorkoutLogStore.save(sheet, exercises: [LoggableExercise("Cable Fly", 3)],
                                           day: .mon, date: TestSupport.etDate(2026, 6, 1), existing: nil, in: ctx)
        let s = sets(log, "Cable Fly")
        XCTAssertEqual(s.map(\.1), [135, 135.5, 42.5])
        XCTAssertEqual(s.map(\.2), [8, 10, 12])

        XCTAssertEqual(WorkoutLogStore.parseWeight("135,5"), 135.5)
        XCTAssertEqual(WorkoutLogStore.parseWeight(" 95 "), 95)
        XCTAssertNil(WorkoutLogStore.parseWeight(""))
        XCTAssertNil(WorkoutLogStore.parseWeight("abc"))
        XCTAssertNil(WorkoutLogStore.parseWeight("1,2,3"))
        XCTAssertEqual(WorkoutLogStore.parseReps(" 7 "), 7)
        XCTAssertNil(WorkoutLogStore.parseReps("7.5"))
    }

    func testFailedSaveThrowsAndRollsBack() throws {
        let existing = TestSupport.makeLog(in: ctx, date: TestSupport.etDate(2026, 6, 1, hour: 0), sets: [
            ("Face Pulls", 1, 40, 15),
        ])
        try ctx.save()

        var sheet = SetSheet(log: existing)
        sheet["Face Pulls", .weight, 1] = "50"
        sheet["Cable Fly", .weight, 1] = "30"

        XCTAssertThrowsError(try WorkoutLogStore.save(
            sheet, exercises: [LoggableExercise("Face Pulls", 3), LoggableExercise("Cable Fly", 3)],
            day: .mon, date: existing.date, existing: existing, in: ctx,
            commit: { _ in throw Boom() })) { error in
            XCTAssertEqual(error.localizedDescription, "disk full")
        }

        XCTAssertFalse(ctx.hasChanges)
        let stored = try ctx.fetch(FetchDescriptor<SetEntry>())
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.exerciseName, "Face Pulls")
        XCTAssertEqual(stored.first?.weight, 40)
    }

    func testFailedSaveOfANewLogLeavesNothingBehind() throws {
        var sheet = SetSheet()
        sheet["Face Pulls", .reps, 1] = "15"
        XCTAssertThrowsError(try WorkoutLogStore.save(
            sheet, exercises: [LoggableExercise("Face Pulls", 3)], day: .mon,
            date: TestSupport.etDate(2026, 6, 1), existing: nil, in: ctx,
            commit: { _ in throw Boom() }))
        XCTAssertEqual(try allLogs().count, 0)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<SetEntry>()).count, 0)
    }
}
