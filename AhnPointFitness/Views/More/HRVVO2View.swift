import SwiftUI

struct HRVVO2View: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InfoBlock(title: "How This Plan Raises Your HRV",
                      paragraphs: TodayContent.hrvHowThisPlanRaises)
            InfoBlock(title: "VO2max Push (Weeks 5–8)",
                      paragraphs: TodayContent.vo2Push)
        }
    }
}
