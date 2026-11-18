import SwiftUI

/// The one stretch routine for today, plus the desk reset on workdays.
///
/// The Stretch tab is a library; this card is the answer to "which one
/// today?", so there is nothing to decide before pressing Start.
struct TodayStretchCard: View {
    let day: ProgrammeDay
    @EnvironmentObject private var session: StretchSessionState
    @State private var presented: StretchRoutine?

    var body: some View {
        let evening = StretchSchedule.evening(for: day)
        let desk = StretchSchedule.desk(for: day)

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                icon(evening.focus.symbol)
                VStack(alignment: .leading, spacing: 2) {
                    Text(evening.name)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Theme.text)
                    Text(evening.subtitle)
                        .font(Typography.cardSubtitle)
                        .foregroundStyle(Theme.text3)
                }
                Spacer(minLength: 8)
                Text(evening.durationLabel)
                    .font(Typography.chip)
                    .foregroundStyle(Theme.text2)
            }

            Button { presented = evening } label: {
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
            .padding(.top, 12)

            if let desk {
                Divider().overlay(Theme.border).padding(.vertical, 12)
                Button { presented = desk } label: {
                    HStack(spacing: 12) {
                        icon(desk.focus.symbol)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(desk.name)
                                .font(Typography.exerciseNameSm)
                                .foregroundStyle(Theme.text)
                            Text("Once, after lunch · in the chair")
                                .font(Typography.cardSubtitle)
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer(minLength: 8)
                        Text(desk.durationLabel)
                            .font(Typography.chip)
                            .foregroundStyle(Theme.text2)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                    }
                }
                .buttonStyle(.plain)
            }

            Text("Not feeling it? Press Start and do the first position. That counts.")
                .font(Typography.bodySm)
                .foregroundStyle(Theme.text3)
                .padding(.top, 12)
        }
        .padding(Theme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius).stroke(Theme.border, lineWidth: 1))
        .padding(.bottom, 12)
        .fullScreenCover(item: $presented) { routine in
            StretchPlayerView(routine: routine)
                .environmentObject(session)
        }
    }

    private func icon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Theme.accent)
            .frame(width: 26, height: 26)
            .background(Theme.accentBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
