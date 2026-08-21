import SwiftUI

/// Pointer row shown on a lift day where its stretch list used to be inline.
/// Launches the same guided session the Stretch tab runs.
struct StretchRoutineLink: View {
    let day: ProgrammeDay
    @EnvironmentObject private var session: StretchSessionState
    @State private var presented: StretchRoutine?

    var body: some View {
        if let routine = StretchLibrary.routine(for: day) {
            Button { presented = routine } label: {
                HStack(spacing: 12) {
                    Image(systemName: "figure.flexibility")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.orange)
                        .frame(width: 28, height: 28)
                        .background(Theme.orangeBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Run guided session")
                            .font(Typography.exerciseName)
                            .foregroundStyle(Theme.orange)
                        Text("\(routine.steps.count) stretches · \(routine.durationLabel) · in the Stretch tab")
                            .font(Typography.bodySm)
                            .foregroundStyle(Theme.text3)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.orange)
                }
                .padding(.horizontal, Theme.rowPaddingH)
                .padding(.vertical, Theme.rowPaddingV)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.stretchRowBg)
                .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
                .overlay(RoundedRectangle(cornerRadius: Theme.rowRadius)
                    .stroke(Theme.stretchRowStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .fullScreenCover(item: $presented) { r in
                StretchPlayerView(routine: r).environmentObject(session)
            }
        }
    }
}
