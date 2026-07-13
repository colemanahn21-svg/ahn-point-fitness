import SwiftUI

struct FuelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Training Day · ~2,300 kcal · ~195g P")
            mealsCard(FuelContent.trainingDay)

            SectionLabel(text: "Rest Day · ~1,850 kcal · ~195g P")
            mealsCard(FuelContent.restDay)

            SectionLabel(text: "Social Night · ~2,200 kcal")
            mealsCard(FuelContent.socialNight)

            SectionLabel(text: "Alcohol Rules")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(FuelContent.alcoholRules.enumerated()), id: \.offset) { idx, rule in
                        RuleItem(rule, isLast: idx == FuelContent.alcoholRules.count - 1)
                    }
                }
            }

            SectionLabel(text: "Dining Out (2–3x/week)")
            Card {
                VStack(spacing: 0) {
                    ForEach(Array(FuelContent.diningRules.enumerated()), id: \.offset) { idx, rule in
                        RuleItem(segments: [
                            .bold(rule.bold),
                            .text(rule.rest)
                        ], isLast: idx == FuelContent.diningRules.count - 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func mealsCard(_ meals: [MealDef]) -> some View {
        Card {
            VStack(spacing: 0) {
                ForEach(Array(meals.enumerated()), id: \.element.id) { idx, meal in
                    MealRow(meal: meal, isLast: idx == meals.count - 1)
                }
            }
        }
    }
}
