import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var restTimer: RestTimerState
    @Query(sort: [SortDescriptor(\WorkoutLog.date, order: .reverse)])
    private var allLogs: [WorkoutLog]

    @State private var selectedDay: ProgrammeDay = .mon
    @State private var sheet = SetSheet()
    @State private var showSaveConfirm: Bool = false
    @State private var saveError: String?
    @State private var showClearAlert: Bool = false
    @State private var showSettings: Bool = false
    @State private var progressTarget: ProgressTarget?
    @State private var expandedHistory: Set<UUID> = []
    @State private var editTarget: WorkoutLog?

    // Tue Lift A is a user-chosen variant. Sets are saved under the active
    // variant's name so each option has an isolated history.
    @AppStorage(LiftVariant.storageKey) private var tueLiftAVariant: String = LiftVariant.fallback.rawValue

    private struct ProgressTarget: Identifiable {
        let id: String   // exercise name doubles as identity
    }

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    private var headerDateString: String {
        let f = DateFormatter()
        f.timeZone = Self.etTZ
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f.string(from: Date())
    }

    private var exercises: [LoggableExercise] {
        Programme.loggable(for: selectedDay, variant: LiftVariant.resolve(stored: tueLiftAVariant))
    }

    private var existingTodayLog: WorkoutLog? {
        WorkoutLogStore.log(for: selectedDay, on: Date(), in: allLogs)
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
                        options: LiftVariant.allCases.map(\.rawValue),
                        active: LiftVariant.resolve(stored: tueLiftAVariant).rawValue,
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

                if let saveError {
                    Text("Not saved: \(saveError)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                } else if showSaveConfirm {
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
        sheet = SetSheet(log: existingTodayLog)
        saveError = nil
    }

    // MARK: - Save

    private func save() {
        do {
            try WorkoutLogStore.save(
                sheet,
                exercises: exercises,
                day: selectedDay,
                date: Date(),
                existing: existingTodayLog,
                in: ctx
            )
        } catch {
            withAnimation {
                showSaveConfirm = false
                saveError = error.localizedDescription
            }
            return
        }

        saveError = nil
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
        sheet = SetSheet()
    }
}
