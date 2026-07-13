import SwiftUI

struct MealRow: View {
    let meal: MealDef
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Text(meal.time)
                    .font(Typography.mealTime)
                    .foregroundStyle(Theme.accent)
                    .frame(minWidth: 62, alignment: .leading)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 3) {
                    Text(meal.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(meal.detail)
                        .font(Typography.bodySm)
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(3)
                    if let macros = meal.macros {
                        Text(macros)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Theme.green)
                            .padding(.top, 3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            if !isLast {
                Rectangle().fill(Theme.border).frame(height: 1)
            }
        }
    }
}
