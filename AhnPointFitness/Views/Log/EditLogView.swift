import SwiftUI
import SwiftData

/// Edit an existing saved workout log. Reuses SetInputRow, mirrors LogView's
/// inputs-dict pattern, and rewrites only this log's sets on save.
/// Date and day are intentionally immutable (export dedup keys off them).
struct EditLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let log: WorkoutLog

    @State private var inputs: [String: [String: String]] = [:]
    @State private var keyboardHeight: CGFloat = 0

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private var day: ProgrammeDay { ProgrammeDay(rawValue: log.day) ?? .mon }

    private var titleString: String {
        let f = DateFormatter()
        f.timeZone = Self.etTZ
        f.dateFormat = "M/d"
        let dayLabel = LogContent.dayDisplay[day] ?? log.day
        return "\(dayLabel) · \(f.string(from: log.date))"
    }

    /// The day's programmed exercises plus any extra names present in the
    /// log's sets (covers the inactive Tue Lift A variant).
    private var exercises: [LoggableExercise] {
        var base = LogContent.exercises[day] ?? []
        let baseNames = Set(base.map(\.name))
        let extraNames = Set(log.sets.map(\.exerciseName)).subtracting(baseNames)
        for name in extraNames.sorted() {
            let maxSet = log.sets.filter { $0.exerciseName == name }
                .map(\.setNumber).max() ?? 3
            base.append(LoggableExercise(name, maxSet))
        }
        return base
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(exercises, id: \.name) { ex in
                            exerciseCard(ex)
                        }
                    }
                    .padding(.horizontal, Theme.pagePaddingH)
                    .padding(.top, Theme.pagePaddingV)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle(titleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
        // Same keyboard-Done pattern as ContentView — sheets are a separate
        // presentation layer, so the main overlay doesn't reach here.
        .overlay(alignment: .bottomTrailing) {
            if keyboardHeight > 0 {
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                } label: {
                    HStack(spacing: 6) {
                        Text("Done")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, keyboardHeight + 8)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.2), value: keyboardHeight > 0)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .onAppear { loadInputs() }
    }

    // MARK: - Exercise card (input-only variant of LogView's tracker card)

    @ViewBuilder
    private func exerciseCard(_ ex: LoggableExercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ex.name)
                .font(Typography.exerciseName)
                .foregroundStyle(Theme.text)

            VStack(spacing: 8) {
                ForEach(1...ex.sets, id: \.self) { s in
                    SetInputRow(
                        setNumber: s,
                        weight: binding(for: ex.name, field: "w-\(s)"),
                        reps: binding(for: ex.name, field: "r-\(s)")
                    )
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
        .padding(.bottom, 10)
    }

    // MARK: - Inputs

    private func binding(for exercise: String, field: String) -> Binding<String> {
        Binding(
            get: { inputs[exercise]?[field] ?? "" },
            set: { newValue in
                var d = inputs[exercise] ?? [:]
                d[field] = newValue
                inputs[exercise] = d
            }
        )
    }

    private func loadInputs() {
        inputs = [:]
        for s in log.sets {
            var d = inputs[s.exerciseName] ?? [:]
            if let w = s.weight { d["w-\(s.setNumber)"] = formatWeight(w) }
            if let r = s.reps { d["r-\(s.setNumber)"] = String(r) }
            inputs[s.exerciseName] = d
        }
    }

    // MARK: - Save

    private func save() {
        // Rewrite sets for every exercise shown in this editor, scoped to
        // this log only (same delete-and-recreate pattern as LogView.save).
        let visibleNames = Set(exercises.map(\.name))
        let toDelete = log.sets.filter { visibleNames.contains($0.exerciseName) }
        for s in toDelete { ctx.delete(s) }
        log.sets.removeAll { visibleNames.contains($0.exerciseName) }

        for ex in exercises {
            for s in 1...ex.sets {
                let wStr = inputs[ex.name]?["w-\(s)"] ?? ""
                let rStr = inputs[ex.name]?["r-\(s)"] ?? ""
                guard !wStr.isEmpty || !rStr.isEmpty else { continue }
                let w = Double(wStr)
                let r = Int(rStr)
                let entry = SetEntry(exerciseName: ex.name, setNumber: s, weight: w, reps: r, log: log)
                ctx.insert(entry)
                log.sets.append(entry)
            }
        }

        try? ctx.save()
        dismiss()
    }
}
