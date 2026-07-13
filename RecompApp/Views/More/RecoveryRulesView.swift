import SwiftUI

struct RecoveryRulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZoneCard(label: "GREEN (67%+)",
                     color: Theme.green, bg: Theme.greenBg,
                     rules: TodayContent.zoneGreen)
            ZoneCard(label: "YELLOW (34–66%)",
                     color: Theme.yellow, bg: Theme.yellowBg,
                     rules: TodayContent.zoneYellow)
            ZoneCard(label: "RED (<34%)",
                     color: Theme.red, bg: Theme.redBg,
                     rules: TodayContent.zoneRed)

            InfoBlock(title: TodayContent.threeDayRedRule.title,
                      text: TodayContent.threeDayRedRule.body)
                .padding(.top, 12)
        }
    }
}
