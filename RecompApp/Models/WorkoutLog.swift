import Foundation
import SwiftData

@Model
final class WorkoutLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var day: String
    @Relationship(deleteRule: .cascade, inverse: \SetEntry.log)
    var sets: [SetEntry]

    init(id: UUID = UUID(), date: Date, day: String, sets: [SetEntry] = []) {
        self.id = id
        self.date = date
        self.day = day
        self.sets = sets
    }
}
