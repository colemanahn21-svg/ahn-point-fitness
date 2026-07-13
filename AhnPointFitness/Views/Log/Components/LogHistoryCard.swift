import SwiftUI

/// The History card on the Log tab. The parent owns the `@Query` and passes
/// `logs` in, so SwiftData reactivity stays with the parent.
struct LogHistoryCard: View {
    let logs: [WorkoutLog]
    @Binding var expandedHistory: Set<UUID>
    let onEdit: (WorkoutLog) -> Void
    let onClear: () -> Void

    private static let etTZ = TimeZone(identifier: "America/New_York")!

    var body: some View {
        Card {
            if logs.isEmpty {
                Text("No logs yet. Save your first workout above.")
                    .font(Typography.body)
                    .foregroundStyle(Theme.text3)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(logs.prefix(30).enumerated()), id: \.element.id) { idx, log in
                        historyRow(log: log, isLast: idx == min(logs.count, 30) - 1)
                    }
                }

                Button {
                    onClear()
                } label: {
                    Text("Clear All History")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - History row

    @ViewBuilder
    private func historyRow(log: WorkoutLog, isLast: Bool) -> some View {
        let day = ProgrammeDay(rawValue: log.day) ?? .mon
        let dayLabel = LogContent.dayDisplay[day] ?? log.day
        let dateStr: String = {
            let f = DateFormatter()
            f.timeZone = Self.etTZ
            f.dateFormat = "M/d"
            return f.string(from: log.date)
        }()
        let isExpanded = expandedHistory.contains(log.id)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isExpanded { expandedHistory.remove(log.id) } else { expandedHistory.insert(log.id) }
                }
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Text(dateStr)
                            .font(Typography.historyMono)
                            .foregroundStyle(Theme.text3)
                        Text(dayLabel)
                            .font(Typography.bodySm)
                            .foregroundStyle(Theme.text2)
                    }
                    Spacer()
                    Text(isExpanded ? "▴ hide" : "▾ details")
                        .font(Typography.historyMono)
                        .foregroundStyle(Theme.green)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .overlay(alignment: .trailing) {
                Button {
                    onEdit(log)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text3)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit log")
                .offset(x: -64)
            }

            if isExpanded {
                let grouped = Dictionary(grouping: log.sets, by: { $0.exerciseName })
                let orderedNames = (LogContent.exercises[day] ?? []).map(\.name)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(orderedNames.filter { grouped[$0] != nil }, id: \.self) { name in
                        let sets = (grouped[name] ?? []).sorted { $0.setNumber < $1.setNumber }
                        let nonEmpty = sets.filter { $0.weight != nil || $0.reps != nil }
                        if !nonEmpty.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                Text(nonEmpty.map { s in
                                    let w = s.weight.map { formatWeight($0) } ?? "—"
                                    let r = s.reps.map { String($0) } ?? "—"
                                    return "S\(s.setNumber): \(w)lb×\(r)"
                                }.joined(separator: "  "))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(Theme.text2)
                            }
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 12)
            }

            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}
