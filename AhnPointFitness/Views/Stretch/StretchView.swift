import SwiftUI

struct StretchView: View {
    @EnvironmentObject private var session: StretchSessionState
    @State private var presented: StretchRoutine?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Golf · Rotation")
            ForEach(StretchLibrary.golfRoutines) { routine in
                RoutineCard(routine: routine) { presented = routine }
            }

            SectionLabel(text: "Post-Lift + Full Body")
                .padding(.top, 8)
            ForEach(StretchLibrary.dayRoutines) { routine in
                RoutineCard(routine: routine) { presented = routine }
            }
        }
        .fullScreenCover(item: $presented) { routine in
            StretchPlayerView(routine: routine)
                .environmentObject(session)
        }
    }
}

extension StretchRoutine: Equatable {
    static func == (a: StretchRoutine, b: StretchRoutine) -> Bool { a.id == b.id }
}

private struct RoutineCard: View {
    let routine: StretchRoutine
    let start: () -> Void
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: routine.focus.symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 26, height: 26)
                    .background(Theme.accentBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.name)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Theme.text)
                    Text(routine.subtitle)
                        .font(Typography.cardSubtitle)
                        .foregroundStyle(Theme.text3)
                }
                Spacer(minLength: 8)

                Text(routine.durationLabel)
                    .font(Typography.chip)
                    .foregroundStyle(Theme.text2)
            }

            HStack(spacing: 8) {
                Button(action: start) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("Start")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        expanded.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(expanded ? "Hide" : "\(routine.steps.count) stretches")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                    .foregroundStyle(Theme.text2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
            .padding(.top, 12)

            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(routine.phases) { phase in
                        Text(phase.label.uppercased())
                            .font(Typography.sectionLabel)
                            .foregroundStyle(Theme.text3)
                            .padding(.top, 12)
                            .padding(.bottom, 6)
                        ForEach(phase.steps) { step in
                            HStack(alignment: .top, spacing: 8) {
                                Text(step.name)
                                    .font(Typography.exerciseNameSm)
                                    .foregroundStyle(Theme.orange)
                                Spacer(minLength: 8)
                                Text(step.chips.joined(separator: " · "))
                                    .font(Typography.chip)
                                    .foregroundStyle(Theme.text3)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Theme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius).stroke(Theme.border, lineWidth: 1))
        .padding(.bottom, 12)
    }
}
