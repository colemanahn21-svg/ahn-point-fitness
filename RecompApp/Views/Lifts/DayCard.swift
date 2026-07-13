import SwiftUI

struct DayCard: View {
    let day: DayContent
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.title)
                            .font(Typography.cardTitle)
                            .foregroundStyle(Theme.text)
                        Text(day.subtitle)
                            .font(Typography.cardSubtitle)
                            .foregroundStyle(Theme.text3)
                    }
                    Spacer(minLength: 8)
                    TagPill(kind: day.tag)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(day.sections.enumerated()), id: \.offset) { _, section in
                        sectionView(section)
                    }
                }
                .padding(.top, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Theme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func sectionView(_ section: DayContent.Section) -> some View {
        switch section {
        case .intro(let text):
            Text(text)
                .font(Typography.body)
                .foregroundStyle(Theme.text2)
                .lineSpacing(3)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .groups(let groups):
            ForEach(groups) { group in
                VStack(alignment: .leading, spacing: 0) {
                    if let label = group.label {
                        GroupLabel(text: label, color: groupColor(group.labelColor))
                    }
                    ForEach(group.exercises) { ex in
                        ExerciseRow(exercise: ex)
                    }
                }
                .padding(.bottom, 10)
            }

        case .cardioFinisher(let title, let options, let note):
            if !title.isEmpty {
                SectionDivider(text: title)
            }
            ForEach(options) { opt in CardioRow(item: opt) }
            if let note = note {
                InfoBlock(title: nil, text: note)
                    .padding(.top, 8)
            }

        case .stretchBlocks(let title, let blocks):
            SectionDivider(text: title, color: Theme.orange)
            ForEach(blocks) { block in
                VStack(alignment: .leading, spacing: 0) {
                    GroupLabel(text: block.label, color: Theme.orange)
                    ForEach(block.stretches) { s in StretchRow(stretch: s) }
                }
                .padding(.bottom, 10)
            }

        case .mobility(let title, let block):
            SectionDivider(text: title, color: Theme.green)
            VStack(alignment: .leading, spacing: 0) {
                GroupLabel(text: block.label, color: Theme.green)
                ForEach(block.items) { m in MobilityRow(item: m) }
            }
            .padding(.bottom, 10)

        case .abCircuit(let title, let groupLabel, let items):
            SectionDivider(text: title)
            VStack(alignment: .leading, spacing: 0) {
                GroupLabel(text: groupLabel)
                ForEach(items) { i in AbRow(exercise: i) }
            }
            .padding(.bottom, 10)

        case .saunaNote(let body):
            InfoBlock(title: nil,
                      paragraphs: [.plain(body)],
                      leftBorder: Theme.orange,
                      tintedText: Theme.orange)
                .padding(.top, 4)

        case .hiftFinisher(let title, let heading, let body, let footer):
            SectionDivider(text: title, color: Theme.orange)
            VStack(alignment: .leading, spacing: 8) {
                Text(heading)
                    .font(Typography.infoTitle)
                    .foregroundStyle(Theme.orange)
                Text(body)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(3)
                Text(footer)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .padding(.bottom, 10)

        case .conditioningCircuit(let title, let heading, let body, let footer):
            SectionDivider(text: title, color: Theme.orange)
            VStack(alignment: .leading, spacing: 8) {
                Text(heading)
                    .font(Typography.infoTitle)
                    .foregroundStyle(Theme.orange)
                Text(body)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(3)
                Text(footer)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rowRadius))
            .padding(.bottom, 10)

        case .infoBlock(let title, let body):
            InfoBlock(title: title, text: body)

        case .warmupBlock(let label, let items):
            VStack(alignment: .leading, spacing: 0) {
                GroupLabel(text: label, color: Theme.purple)
                ForEach(items) { i in WarmupRow(item: i) }
            }
            .padding(.bottom, 10)

        case .mobilityPrimer(let dividerTitle, let label, let items):
            SectionDivider(text: dividerTitle, color: Theme.purple)
            VStack(alignment: .leading, spacing: 0) {
                GroupLabel(text: label, color: Theme.purple)
                ForEach(items) { i in WarmupRow(item: i) }
            }
            .padding(.bottom, 10)
        }
    }

    private func groupColor(_ c: GroupBlock.Color?) -> Color {
        switch c {
        case .orange: return Theme.orange
        case .purple: return Theme.purple
        default: return Theme.text2
        }
    }
}
