import SwiftUI

struct DayChipSelector: View {
    @Binding var selected: ProgrammeDay
    let days: [ProgrammeDay]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selected = day
                        }
                    } label: {
                        Text(day.short)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selected == day ? .white : Theme.text2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selected == day ? Theme.accent : Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selected == day ? Theme.accent : Theme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 16)
    }
}
