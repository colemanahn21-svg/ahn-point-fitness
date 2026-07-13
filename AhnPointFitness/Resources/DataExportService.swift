import Foundation
import SwiftData

// MARK: - Wire format

struct ExportPayload: Codable {
    let exportDate: Date
    let exportVersion: Int
    let appVersion: String
    let totalLogs: Int
    let totalSets: Int
    let logs: [LogPayload]
}

struct LogPayload: Codable {
    let id: UUID
    let date: Date
    let day: String
    let sets: [SetPayload]
}

struct SetPayload: Codable {
    let id: UUID
    let exerciseName: String
    let setNumber: Int
    let weight: Double?
    let reps: Int?
}

// MARK: - Service

enum DataExportService {
    static let currentVersion = 1

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    private static var appVersion: String {
        let info = Bundle.main.infoDictionary
        return (info?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    // MARK: Encode (off-main safe)

    static func encode(_ logs: [WorkoutLog]) throws -> Data {
        let logPayloads: [LogPayload] = logs.map { log in
            let sets = log.sets
                .sorted { $0.setNumber < $1.setNumber }
                .map { s in
                    SetPayload(
                        id: s.id,
                        exerciseName: s.exerciseName,
                        setNumber: s.setNumber,
                        weight: s.weight,
                        reps: s.reps
                    )
                }
            return LogPayload(id: log.id, date: log.date, day: log.day, sets: sets)
        }
        let totalSets = logPayloads.reduce(0) { $0 + $1.sets.count }
        let payload = ExportPayload(
            exportDate: Date(),
            exportVersion: currentVersion,
            appVersion: appVersion,
            totalLogs: logPayloads.count,
            totalSets: totalSets,
            logs: logPayloads
        )
        return try encoder.encode(payload)
    }

    // MARK: Decode (off-main safe)

    static func decode(_ data: Data) throws -> ExportPayload {
        try decoder.decode(ExportPayload.self, from: data)
    }

    // MARK: File write (off-main safe)

    static func writeTempFile(_ data: Data, dateET: Date = Date()) throws -> URL {
        let f = DateFormatter()
        f.timeZone = etTZ
        f.dateFormat = "yyyy-MM-dd"
        let stamp = f.string(from: dateET)
        let filename = "ahn-point-logs-\(stamp).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: Merge import (main-actor — touches SwiftData)

    struct ImportCounts {
        let imported: Int
        let skipped: Int
    }

    static func mergeImport(
        _ payload: ExportPayload,
        into ctx: ModelContext,
        existing: [WorkoutLog]
    ) -> ImportCounts {
        var imported = 0
        var skipped = 0

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = etTZ

        struct CompositeKey: Hashable {
            let day: String
            let year: Int
            let month: Int
            let dayOfMonth: Int
        }
        func compositeKey(day: String, date: Date) -> CompositeKey {
            let comps = cal.dateComponents([.year, .month, .day], from: date)
            return CompositeKey(
                day: day,
                year: comps.year ?? 0,
                month: comps.month ?? 0,
                dayOfMonth: comps.day ?? 0
            )
        }

        let existingIDs = Set(existing.map(\.id))
        let existingKeys = Set(existing.map { compositeKey(day: $0.day, date: $0.date) })

        for src in payload.logs {
            let key = compositeKey(day: src.day, date: src.date)
            if existingIDs.contains(src.id) || existingKeys.contains(key) {
                skipped += 1
                continue
            }

            let log = WorkoutLog(id: src.id, date: src.date, day: src.day, sets: [])
            ctx.insert(log)
            for s in src.sets {
                let entry = SetEntry(
                    id: s.id,
                    exerciseName: s.exerciseName,
                    setNumber: s.setNumber,
                    weight: s.weight,
                    reps: s.reps,
                    log: log
                )
                ctx.insert(entry)
                log.sets.append(entry)
            }
            imported += 1
        }

        try? ctx.save()
        return ImportCounts(imported: imported, skipped: skipped)
    }
}
