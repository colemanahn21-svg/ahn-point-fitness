import SwiftUI

struct BaselineView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Your Baseline")
            StatGrid(stats: TodayContent.stats)
        }
    }
}
