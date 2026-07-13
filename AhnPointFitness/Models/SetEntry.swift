import Foundation
import SwiftData

@Model
final class SetEntry {
    @Attribute(.unique) var id: UUID
    var exerciseName: String
    var setNumber: Int
    var weight: Double?
    var reps: Int?
    var log: WorkoutLog?

    init(id: UUID = UUID(),
         exerciseName: String,
         setNumber: Int,
         weight: Double? = nil,
         reps: Int? = nil,
         log: WorkoutLog? = nil) {
        self.id = id
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.log = log
    }
}
