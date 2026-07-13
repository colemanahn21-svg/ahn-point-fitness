import SwiftUI

struct SleepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Sleep Schedule")
            Card {
                VStack(spacing: 0) {
                    HStack {
                        Text("Day")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 50, alignment: .leading)
                        Text("Bed")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Wake")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Hrs")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.bottom, 8)
                    Rectangle().fill(Theme.border).frame(height: 1)

                    ForEach(Array(SleepContent.schedule.enumerated()), id: \.element.id) { idx, row in
                        scheduleRow(row, isLast: idx == SleepContent.schedule.count - 1)
                    }
                }
            }

            InfoBlock(title: "Why This Matters",
                      paragraphs: SleepContent.whyItMatters)

            SectionLabel(text: "Wind-Down Protocol")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(SleepContent.windDown.enumerated()), id: \.element.id) { idx, meal in
                        MealRow(meal: meal, isLast: idx == SleepContent.windDown.count - 1)
                    }
                }
            }

            SectionLabel(text: "Full Supplement Stack")
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    stackHeader("MORNING (9:00 AM with Meal 1)", color: Theme.accent)
                    ForEach(Array(SleepContent.morningSupps.enumerated()), id: \.element.id) { idx, s in
                        SupplementRow(supp: s, isLast: idx == SleepContent.morningSupps.count - 1)
                    }
                    stackHeader("CAFFEINE (morning, with coffee)", color: Theme.green)
                    ForEach(Array(SleepContent.caffeineSupps.enumerated()), id: \.element.id) { idx, s in
                        SupplementRow(supp: s, isLast: idx == SleepContent.caffeineSupps.count - 1)
                    }
                    stackHeader("NIGHTTIME (10:00–10:30 PM)", color: Theme.purple)
                    ForEach(Array(SleepContent.nightSupps.enumerated()), id: \.element.id) { idx, s in
                        SupplementRow(supp: s, isLast: idx == SleepContent.nightSupps.count - 1)
                    }
                }
            }

            InfoBlock(title: SleepContent.socialNightsInfo.title,
                      text: SleepContent.socialNightsInfo.body)
        }
    }

    @ViewBuilder
    private func stackHeader(_ text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .padding(.top, 12)
                .padding(.bottom, 8)
            Rectangle().fill(Theme.border).frame(height: 1)
        }
    }

    @ViewBuilder
    private func scheduleRow(_ row: SleepRow, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(row.day)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .frame(width: 50, alignment: .leading)
                Text(row.bed)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(row.wake)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(row.hrs)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Theme.green)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, row.isSocial ? 8 : 0)
            .background(row.isSocial ? Theme.yellowRowBg : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}
