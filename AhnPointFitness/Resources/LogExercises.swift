import Foundation

struct LoggableExercise: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let sets: Int
    init(_ name: String, _ sets: Int) { self.name = name; self.sets = sets }
}

enum LogContent {
    static let orderedDays: [ProgrammeDay] = [.mon, .tue, .thu, .fri, .sat]

    static let dayDisplay: [ProgrammeDay: String] = [
        .mon: "Mon·Back+Chest",
        .tue: "Tue·Legs",
        .thu: "Thu·Arms+Shoulders",
        .fri: "Fri·Athletic Upper",
        .sat: "Sat·Athletic Conditioning"
    ]

    static let exercises: [ProgrammeDay: [LoggableExercise]] = [
        .mon: [
            .init("Barbell Bench Press", 4),
            .init("Barbell Bent-Over Row", 4),
            .init("Incline DB Press", 3),
            .init("Chest-Supported DB Row", 3),
            .init("Cable Fly", 3),
            .init("Straight-Arm Pulldown", 3),
            .init("Face Pulls", 3)
        ],
        .tue: [
            .init("Trap Bar Squat", 4),
            .init("Romanian Deadlift", 4),
            .init("Walking Lunges (DB)", 3),
            .init("Leg Curl", 3),
            .init("Leg Press", 3),
            .init("Standing Calf Raise", 4)
        ],
        .thu: [
            .init("Seated DB OHP", 4),
            .init("EZ-Bar Curl", 3),
            .init("Cable Lateral Raise", 3),
            .init("OH Tricep Extension", 3),
            .init("Reverse Pec Deck", 3),
            .init("Hammer Curl", 3),
            .init("Dip Machine / CG Bench", 3),
            .init("Incline DB Curl", 3)
        ],
        .fri: [
            .init("Med Ball Supine Throw", 2),
            .init("Explosive Pull-Up", 2),
            .init("SA DB Row (staggered)", 3),
            .init("SA DB Push Press", 3),
            .init("Landmine Row", 3),
            .init("Landmine Press (half-kneel)", 3),
            .init("Cable Face Pull", 2),
            .init("Cable Pallof Press", 2),
            .init("Cable Chop", 2)
        ],
        .sat: [
            .init("Box Jump", 3),
            .init("Lateral Bound", 3),
            .init("Med Ball Rotational Slam", 3),
            .init("Farmer's Carry", 2),
            .init("Overhead Carry", 2),
            .init("Bear Crawl", 2)
        ]
    ]
}
