import XCTest
@testable import AhnPointFitness

/// Fabricates WHOOP v2 records by decoding JSON — same path production data
/// takes — and checks WhoopTodaySnapshot.compute's derivations.
final class WhoopSnapshotTests: XCTestCase {
    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func stamp(daysAgo: Double) -> String {
        Self.iso.string(from: Date().addingTimeInterval(-daysAgo * 86_400))
    }

    private func recovery(daysAgo: Double, score: Double, hrv: Double) throws -> RecoveryRecord {
        let json = """
        {
          "cycle_id": \(Int(daysAgo * 100) + 1),
          "user_id": 1,
          "created_at": "\(stamp(daysAgo: daysAgo))",
          "updated_at": "\(stamp(daysAgo: daysAgo))",
          "score_state": "SCORED",
          "score": { "recovery_score": \(score), "hrv_rmssd_milli": \(hrv) }
        }
        """
        return try JSONDecoder().decode(RecoveryRecord.self, from: Data(json.utf8))
    }

    private func cycle(daysAgo: Double, strain: Double) throws -> CycleRecord {
        let json = """
        {
          "id": \(Int(daysAgo * 100) + 1),
          "user_id": 1,
          "created_at": "\(stamp(daysAgo: daysAgo))",
          "updated_at": "\(stamp(daysAgo: daysAgo))",
          "start": "\(stamp(daysAgo: daysAgo))",
          "score_state": "SCORED",
          "score": { "strain": \(strain) }
        }
        """
        return try JSONDecoder().decode(CycleRecord.self, from: Data(json.utf8))
    }

    private func sleep(daysAgo: Double, performance: Double, inBedHours: Double, awakeHours: Double) throws -> SleepRecord {
        let json = """
        {
          "id": "\(UUID().uuidString)",
          "user_id": 1,
          "created_at": "\(stamp(daysAgo: daysAgo))",
          "updated_at": "\(stamp(daysAgo: daysAgo))",
          "start": "\(stamp(daysAgo: daysAgo))",
          "end": "\(stamp(daysAgo: daysAgo - 0.3))",
          "score_state": "SCORED",
          "score": {
            "sleep_performance_percentage": \(performance),
            "stage_summary": {
              "total_in_bed_time_milli": \(Int(inBedHours * 3_600_000)),
              "total_awake_time_milli": \(Int(awakeHours * 3_600_000))
            }
          }
        }
        """
        return try JSONDecoder().decode(SleepRecord.self, from: Data(json.utf8))
    }

    func testLatestRecordsWin() throws {
        let snap = WhoopTodaySnapshot.compute(
            recoveries: [
                try recovery(daysAgo: 3, score: 40, hrv: 45),
                try recovery(daysAgo: 0.2, score: 82, hrv: 55),   // latest
            ],
            cycles: [
                try cycle(daysAgo: 2, strain: 15.0),
                try cycle(daysAgo: 0.1, strain: 9.4),             // latest
            ],
            sleeps: [
                try sleep(daysAgo: 0.4, performance: 88, inBedHours: 8.0, awakeHours: 0.5),
            ]
        )
        XCTAssertEqual(snap.recoveryScore, 82)
        XCTAssertEqual(snap.hrvMilli, 55)
        XCTAssertEqual(snap.dayStrain, 9.4)
        XCTAssertEqual(snap.sleepPerformance, 88)
        XCTAssertEqual(snap.sleepHours ?? 0, 7.5, accuracy: 0.01)
    }

    func testHRVBaselineIsMeanAndDeltaDerives() throws {
        let snap = WhoopTodaySnapshot.compute(
            recoveries: [
                try recovery(daysAgo: 2, score: 60, hrv: 40),
                try recovery(daysAgo: 0.2, score: 70, hrv: 60),   // latest
            ],
            cycles: [], sleeps: []
        )
        XCTAssertEqual(snap.hrvBaselineMilli ?? 0, 50, accuracy: 0.001)
        XCTAssertEqual(snap.hrvDelta ?? 0, 10, accuracy: 0.001)
    }

    func testEmptyInputsProduceEmptySnapshot() {
        let snap = WhoopTodaySnapshot.compute(recoveries: [], cycles: [], sleeps: [])
        XCTAssertNil(snap.recoveryScore)
        XCTAssertNil(snap.hrvMilli)
        XCTAssertNil(snap.dayStrain)
        XCTAssertNil(snap.sleepHours)
        XCTAssertNil(snap.hrvDelta)
    }

    func testSleepHoursSubtractAwakeTime() throws {
        let snap = WhoopTodaySnapshot.compute(
            recoveries: [], cycles: [],
            sleeps: [try sleep(daysAgo: 0.3, performance: 70, inBedHours: 9.0, awakeHours: 1.5)]
        )
        XCTAssertEqual(snap.sleepHours ?? 0, 7.5, accuracy: 0.01)
    }
}
