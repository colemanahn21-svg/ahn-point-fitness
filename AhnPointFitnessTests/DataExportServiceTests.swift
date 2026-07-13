import XCTest
import SwiftData
@testable import AhnPointFitness

@MainActor
final class DataExportServiceTests: XCTestCase {
    var container: ModelContainer!
    var ctx: ModelContext!

    override func setUp() async throws {
        container = try TestSupport.makeContainer()
        ctx = container.mainContext
    }

    private func allLogs() throws -> [WorkoutLog] {
        try ctx.fetch(FetchDescriptor<WorkoutLog>())
    }

    func testEncodeDecodeRoundtrip() throws {
        let log = TestSupport.makeLog(
            in: ctx, date: TestSupport.etDate(2026, 6, 1), day: "tue",
            sets: [("Trap Bar Squat", 1, 225, 6), ("Trap Bar Squat", 2, 225.5, 5)]
        )

        let data = try DataExportService.encode([log])
        let payload = try DataExportService.decode(data)

        XCTAssertEqual(payload.exportVersion, DataExportService.currentVersion)
        XCTAssertEqual(payload.totalLogs, 1)
        XCTAssertEqual(payload.totalSets, 2)
        XCTAssertEqual(payload.logs.first?.id, log.id)
        XCTAssertEqual(payload.logs.first?.day, "tue")
        XCTAssertEqual(payload.logs.first?.sets.map(\.weight), [225, 225.5])
    }

    func testMergeImportIsIdempotent() throws {
        let log = TestSupport.makeLog(
            in: ctx, date: TestSupport.etDate(2026, 6, 1), day: "mon",
            sets: [("Barbell Bench Press", 1, 185, 8)]
        )
        try ctx.save()
        let payload = try DataExportService.decode(DataExportService.encode([log]))

        // Importing into a store that already has the same log: all skipped.
        let counts = DataExportService.mergeImport(payload, into: ctx, existing: try allLogs())
        XCTAssertEqual(counts.imported, 0)
        XCTAssertEqual(counts.skipped, 1)
        XCTAssertEqual(try allLogs().count, 1)
    }

    func testMergeImportAddsNewLogs() throws {
        let log = TestSupport.makeLog(
            in: ctx, date: TestSupport.etDate(2026, 6, 1), day: "mon",
            sets: [("Barbell Bench Press", 1, 185, 8)]
        )
        try ctx.save()
        let payload = try DataExportService.decode(DataExportService.encode([log]))

        // Import into a FRESH store: everything lands.
        let fresh = try TestSupport.makeContainer()
        let freshCtx = fresh.mainContext
        let counts = DataExportService.mergeImport(payload, into: freshCtx, existing: [])
        XCTAssertEqual(counts.imported, 1)
        XCTAssertEqual(counts.skipped, 0)

        let imported = try freshCtx.fetch(FetchDescriptor<WorkoutLog>())
        XCTAssertEqual(imported.count, 1)
        XCTAssertEqual(imported.first?.id, log.id)
        XCTAssertEqual(imported.first?.sets.count, 1)
    }

    func testMergeImportSkipsSameDayDifferentID() throws {
        // Same (day, ET calendar day) but a different UUID must still be skipped.
        _ = TestSupport.makeLog(
            in: ctx, date: TestSupport.etDate(2026, 6, 1, hour: 8), day: "mon",
            sets: [("Row", 1, 120, 10)]
        )
        try ctx.save()

        let clashing = LogPayload(
            id: UUID(),   // new identity
            date: TestSupport.etDate(2026, 6, 1, hour: 20),   // same ET day
            day: "mon",
            sets: []
        )
        let payload = ExportPayload(
            exportDate: Date(), exportVersion: 1, appVersion: "test",
            totalLogs: 1, totalSets: 0, logs: [clashing]
        )

        let counts = DataExportService.mergeImport(payload, into: ctx, existing: try allLogs())
        XCTAssertEqual(counts.imported, 0)
        XCTAssertEqual(counts.skipped, 1)
    }
}
