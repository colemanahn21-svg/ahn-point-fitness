import SwiftUI
import SwiftData

/// Edit an existing saved workout log. Reuses SetInputRow, mirrors LogView's
/// inputs-dict pattern, and rewrites only this log's sets on save.
/// Date and day are intentionally immutable (export dedup keys off them).
struct EditLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let log: WorkoutLog

    @State private var sheet = SetSheet()
    @State private var saveError: String?
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
        var base = Programme.loggable(for: day)
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
        .alert("Not saved", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveError ?? "")
        }
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
                        weight: binding(for: ex.name, field: .weight, set: s),
                        reps: binding(for: ex.name, field: .reps, set: s)
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

    private func binding(for exercise: String, field: SetSheet.Field, set: Int) -> Binding<String> {
        Binding(
            get: { sheet[exercise, field, set] },
            set: { sheet[exercise, field, set] = $0 }
        )
    }

    private func loadInputs() {
        sheet = SetSheet(log: log)
    }

    // MARK: - Save

    /// Rewrites the sets of every exercise shown here, on this log only.
    /// Stays open with a message if the save fails.
    private func save() {
        do {
            try WorkoutLogStore.save(
                sheet,
                exercises: exercises,
                day: day,
                date: log.date,
                existing: log,
                in: ctx
            )
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}
