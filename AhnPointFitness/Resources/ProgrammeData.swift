import Foundation

// MARK: - Exercise data types

struct ExerciseDef: Identifiable {
    let id: String
    let name: String
    let chips: [String]
    let rationale: String?
    init(_ id: String, _ name: String, _ chips: [String], _ rationale: String? = nil) {
        self.id = id; self.name = name; self.chips = chips; self.rationale = rationale
    }
}

struct StretchDef: Identifiable {
    let id: String
    let name: String
    let chips: [String]
    let rationale: String
    init(_ id: String, _ name: String, _ chips: [String], _ rationale: String) {
        self.id = id; self.name = name; self.chips = chips; self.rationale = rationale
    }
}

struct WarmupDef: Identifiable {
    let id: String
    let name: String
    init(_ id: String, _ name: String) { self.id = id; self.name = name }
}

struct MobilityDef: Identifiable {
    let id: String
    let name: String
    init(_ id: String, _ name: String) { self.id = id; self.name = name }
}

struct CardioDef: Identifiable {
    let id: String
    let name: String
    let chips: [String]
    init(_ id: String, _ name: String, _ chips: [String]) {
        self.id = id; self.name = name; self.chips = chips
    }
}

struct GroupBlock: Identifiable {
    let id = UUID()
    let label: String?
    let labelColor: Color?
    let exercises: [ExerciseDef]
    enum Color { case normal, orange, purple }
    init(label: String? = nil, labelColor: Color? = nil, exercises: [ExerciseDef]) {
        self.label = label
        self.labelColor = labelColor
        self.exercises = exercises
    }
}

struct StretchBlock: Identifiable {
    let id = UUID()
    let label: String
    let stretches: [StretchDef]
}

struct MobilityBlock: Identifiable {
    let id = UUID()
    let label: String
    let items: [MobilityDef]
}

struct MealDef: Identifiable {
    let id: String
    let time: String
    let title: String
    let detail: String
    let macros: String?
    init(_ id: String, _ time: String, _ title: String, _ detail: String, _ macros: String? = nil) {
        self.id = id; self.time = time; self.title = title; self.detail = detail; self.macros = macros
    }
}

struct SupplementDef: Identifiable {
    let id: String
    let time: String
    let name: String
    let dose: String
    let note: String
    init(_ id: String, _ time: String, _ name: String, _ dose: String, _ note: String) {
        self.id = id; self.time = time; self.name = name; self.dose = dose; self.note = note
    }
}

// MARK: - Day model

enum ProgrammeDay: String, CaseIterable {
    case mon, tue, wed, thu, fri, sat, sun
    var short: String {
        switch self {
        case .mon: return "Mon"; case .tue: return "Tue"; case .wed: return "Wed"
        case .thu: return "Thu"; case .fri: return "Fri"; case .sat: return "Sat"; case .sun: return "Sun"
        }
    }
}

// MARK: - Day card content shape

struct DayContent {
    enum Section {
        case groups([GroupBlock])
        case cardioFinisher(title: String, options: [CardioDef], note: String?)
        case stretchBlocks(title: String, blocks: [StretchBlock])
        case mobility(title: String, block: MobilityBlock)
        case abCircuit(title: String, groupLabel: String, items: [ExerciseDef])
        case saunaNote(String)
        case hiftFinisher(title: String, heading: String, body: String, footer: String)
        case infoBlock(title: String?, body: String)
        case conditioningCircuit(title: String, heading: String, body: String, footer: String)
        case warmupBlock(label: String, items: [WarmupDef])
        case mobilityPrimer(dividerTitle: String, label: String, items: [WarmupDef])
        case intro(String)
    }

    let day: ProgrammeDay
    let title: String
    let subtitle: String
    let tag: TagKind
    let sections: [Section]
}

// Namespaced programme data — populated across separate files
enum Programme {
    // Aggregate the seven days — concrete values come from Lifts+Monday.swift etc.
    static var allDays: [DayContent] {
        [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
    }
}
