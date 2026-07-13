import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var restTimer: RestTimerState
    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var allLogs: [WorkoutLog]

    @State private var selectedDay: ProgrammeDay = .mon
    @State private var inputs: [String: [String: String]] = [:]   // exerciseName -> [w-S1, r-S1, ...]
    @State private var showSaveConfirm: Bool = false
    @State private var showClearAlert: Bool = false
    @State private var showSettings: Bool = false
    @State private var progressTarget: ProgressTarget?
    @State private var expandedHistory: Set<UUID> = []
    @State private var editTarget: WorkoutLog?

    // Tue Lift A is a user-chosen variant. Sets are saved under the active
    // variant's name so each option has an isolated history.
    @AppStorage("tueLiftAVariant") private var tueLiftAVariant: String = "Barbell Back Squat"
    private static let tueLiftAOptions = ["Trap Bar Squat", "Barbell Back Squat"]

    private struct ProgressTarget: Identifiable {
        let id: String   // exercise name doubles as identity
    }

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private var currentET: Date {
        let now = Date()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = Self.etTZ
        let comps = cal.dateComponents([.year, .month, .day], from: now)
        return cal.date(from: comps) ?? now
    }

    private var headerDateString: String {
        let f = DateFormatter()
        f.timeZone = Self.etTZ
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f.string(from: Date())
    }

    private var exercises: [LoggableExercise] {
        var base = LogContent.exercises[selectedDay] ?? []
        if selectedDay == .tue, let first = base.first {
            base[0] = LoggableExercise(activeTueLiftA, first.sets)
        }
        return base
    }

    private var activeTueLiftA: String {
        Self.tueLiftAOptions.contains(tueLiftAVariant) ? tueLiftAVariant : "Barbell Back Squat"
    }

    private var existingTodayLog: WorkoutLog? {
        let dayKey = selectedDay.rawValue
        let target = currentET
        return allLogs.first { log in
            log.day == dayKey && Calendar(identifier: .gregorian).with(timeZone: Self.etTZ).isDate(log.date, inSameDayAs: target)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RecoveryBanner()

            SectionLabel(text: "Weight Tracker")
            Card {
                HStack {
                    Text(headerDateString)
                        .font(Typography.dataMono)
                        .foregroundStyle(Theme.accent)
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.text2)
                            .padding(6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Settings")
                }
                .padding(.bottom, 12)

                DayChipSelector(selected: $selectedDay, days: LogContent.orderedDays)

                restChips

                if selectedDay == .tue {
                    TueVariantPicker(
                        options: Self.tueLiftAOptions,
                        active: activeTueLiftA,
                        onSelect: { tueLiftAVariant = $0 }
                    )
                }

                ForEach(exercises, id: \.name) { ex in
                    trackerExercise(ex)
                }

                Button {
                    save()
                } label: {
                    Text("Save Workout Log")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.top, 12)

                if showSaveConfirm {
                    Text("✓ Saved")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.green)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
            }

            SectionLabel(text: "History")
            LogHistoryCard(
                logs: allLogs,
                expandedHistory: $expandedHistory,
                onEdit: { editTarget = $0 },
                onClear: { showClearAlert = true }
            )
        }
        .onChange(of: selectedDay) { _, _ in loadInputs() }
        .onChange(of: tueLiftAVariant) { _, _ in loadInputs() }
        .onAppear { loadInputs() }
        .alert("Clear all workout history?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) { clearAllHistory() }
        } message: {
            Text("This removes every saved workout log on this device.")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(.light)
        }
        .sheet(item: $progressTarget) { target in
            ExerciseProgressView(exerciseName: target.id)
                .preferredColorScheme(.light)
        }
        .sheet(item: $editTarget) { log in
            EditLogView(log: log)
                .preferredColorScheme(.light)
        }
    }

    // MARK: - Rest timer chips

    @ViewBuilder
    private var restChips: some View {
        HStack(spacing: 6) {
            Text("REST")
                .font(Typography.setHeader)
                .foregroundStyle(Theme.text3)
                .tracking(0.5)
            ForEach([45, 60, 90, 120], id: \.self) { seconds in
                Button {
                    restTimer.start(seconds: seconds)
                } label: {
                    Text(seconds == 120 ? "2:00" : "\(seconds)s")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.text2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.surface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.bottom, 12)
    }

    // MARK: - Exercise card

    @ViewBuilder
    private func trackerExercise(_ ex: LoggableExercise) -> some View {
        let stats = ExerciseStats.compute(for: ex.name, from: allLogs)

        VStack(alignment: .leading, spacing: 10) {
            Button {
                progressTarget = ProgressTarget(id: ex.name)
            } label: {
                HStack(spacing: 8) {
                    Text(ex.name)
                        .font(Typography.exerciseName)
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text2.opacity(0.4))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            PRLineView(stats: stats)

            HStack(spacing: 8) {
                Spacer().frame(width: 28)
                Text("WEIGHT")
                    .font(Typography.setHeader)
                    .foregroundStyle(Theme.text3)
                    .tracking(0.5)
                    .frame(width: 72, alignment: .center)
                Spacer().frame(width: 24)
                Text("REPS")
                    .font(Typography.setHeader)
                    .foregroundStyle(Theme.text3)
                    .tracking(0.5)
                    .frame(width: 72, alignment: .center)
                Spacer().frame(width: 30)
                Spacer()
            }
            .padding(.bottom, 2)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Theme.border).frame(height: 1)
                    .offset(y: 2)
            }

            VStack(spacing: 8) {
                ForEach(1...ex.sets, id: \.self) { s in
                    let wKey = inputKey(name: ex.name, kind: "w", set: s)
                    let rKey = inputKey(name: ex.name, kind: "r", set: s)
                    SetInputRow(
                        setNumber: s,
                        weight: binding(for: ex.name, field: wKey),
                        reps: binding(for: ex.name, field: rKey)
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

    private func inputKey(name: String, kind: String, set: Int) -> String {
        "\(kind)-\(set)"
    }

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
        guard let log = existingTodayLog else { return }
        for s in log.sets {
            var d = inputs[s.exerciseName] ?? [:]
            if let w = s.weight { d["w-\(s.setNumber)"] = formatWeight(w) }
            if let r = s.reps { d["r-\(s.setNumber)"] = String(r) }
            inputs[s.exerciseName] = d
        }
    }

    // MARK: - Save

    private func save() {
        let dayKey = selectedDay.rawValue
        let target = currentET

        let log = existingTodayLog ?? WorkoutLog(date: target, day: dayKey)
        if log.modelContext == nil {
            ctx.insert(log)
        }

        // Clear previous sets ONLY for currently-visible exercises. This
        // preserves the inactive variant's data (e.g. saving a Barbell Back
        // Squat session must not erase prior Trap Bar Squat sets on the same
        // WorkoutLog).
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

        withAnimation { showSaveConfirm = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSaveConfirm = false }
        }
    }

    private func clearAllHistory() {
        for log in allLogs {
            ctx.delete(log)
        }
        try? ctx.save()
        inputs = [:]
    }
}
