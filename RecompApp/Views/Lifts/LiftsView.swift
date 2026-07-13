import SwiftUI

struct LiftsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Tap any day to expand")
            ForEach(Array(Programme.allDays.enumerated()), id: \.offset) { _, day in
                DayCard(day: day)
            }
        }
    }
}
