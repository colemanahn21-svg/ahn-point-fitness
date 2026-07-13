import Foundation

enum FuelContent {
    static let trainingDay: [MealDef] = [
        .init("td-1", "8:30a", "Wake Up", "16 oz water immediately.", nil),
        .init("td-2", "8:45a", "Coffee", "Your caffeine for the day. Black or with minimal creamer. No sugary additions.", nil),
        .init("td-3", "9:00a", "Supplements", "AG1 + OJ · Arrae protein drink w/ 5g creatine + 5g glutamine · Blissphora", "~25g P"),
        .init("td-4", "9:15a", "Meal 1", "3 eggs scrambled + ¾ cup rice + ½ cup blueberries. Take Vitamin D + Fish Oil with this meal.", "~30g P · 45g C · 15g F"),
        .init("td-5", "12:30p", "Meal 2", "6 oz chicken breast + 1 medium baked potato + 1 cup broccoli.", "~45g P · 40g C · 5g F"),
        .init("td-6", "3:30p", "LIFT + Finisher", "75–90 min total session.", nil),
        .init("td-7", "5:15p", "Post-Workout Shake", "Frozen berries + protein powder + 4 oz OJ + water + 1 tbsp PB.", "~40g P · 40g C · 8g F"),
        .init("td-8", "7:30p", "Meal 3", "6 oz steak or chicken + ¾ cup rice + 1 cup green beans.", "~40g P · 35g C · 10g F"),
        .init("td-9", "9:00p", "Protein Top-Up", "Small shake (protein powder + water) if under 185g protein for the day.", "~15g P"),
        .init("td-10", "9:30p", "⛔ Food Cutoff", "Water and herbal tea only from here. 3 hrs before bed protects HRV.", nil)
    ]

    static let restDay: [MealDef] = [
        .init("rd-1", "9:00a", "Wake + Coffee", "16 oz water + coffee. Black or minimal creamer.", nil),
        .init("rd-2", "9:15a", "Supplements", "AG1/OJ + Arrae drink (creatine, glutamine) + Blissphora", "~25g P"),
        .init("rd-3", "9:45a", "Meal 1", "3 eggs + ½ cup blueberries. No starch. Vitamin D + Fish Oil.", "~22g P · 15g C · 14g F"),
        .init("rd-4", "1:00p", "Meal 2", "6 oz chicken + 1 cup broccoli + 1 cup green beans. No potato.", "~45g P · 15g C · 5g F"),
        .init("rd-5", "4:00p", "Optional Shake", "Protein powder + water. No PB. Only if hungry.", "~30g P"),
        .init("rd-6", "7:00p", "Meal 3", "6 oz steak or chicken + large green salad or green beans.", "~45g P · 10g C · 12g F"),
        .init("rd-7", "9:00p", "Protein Top-Up", "2 eggs or small shake if under 185g protein for the day.", "~15-20g P"),
        .init("rd-8", "9:30p", "⛔ Food Cutoff", "Same 3-hr pre-bed rule.", nil)
    ]

    static let socialNight: [MealDef] = [
        .init("sn-1", "9:00a", "Coffee + Front-Load Protein", "Coffee + supps + 3 eggs + ¾ cup rice + blueberries. Bank protein early.", "~55g P · 45g C"),
        .init("sn-2", "12:30p", "Meal 2", "6 oz chicken or steak + small potato + broccoli. Anchor meal.", "~45g P · 35g C"),
        .init("sn-3", "3:30p", "Lift + Shake", "Don't skip the session. Post-workout shake as usual.", "~40g P"),
        .init("sn-4", "7-10p", "Dinner Out + Drinks", "Protein-centric entrée. 2–4 drinks max. See rules below.", "~30-40g P"),
        .init("sn-5", "10:00p", "Switch to Water", "1 glass water per drink consumed. Alcohol stops here.", nil)
    ]

    static let alcoholRules: [String] = [
        "2–4 drinks max per social night. Fri and/or Sat only.",
        "Last drink 3 hrs before bed. Alcohol within 2 hrs wrecks HRV 15–25%.",
        "1 water between every 2 drinks. 16 oz water before bed.",
        "Vodka soda (~100 cal) > margarita (~400 cal). Skip sugary cocktails.",
        "Never drink the night before heavy legs or back+chest (Mon/Tue).",
        "Next day = yellow recovery minimum regardless of WHOOP score."
    ]

    struct DiningRule {
        let bold: String
        let rest: String
    }

    static let diningRules: [DiningRule] = [
        .init(bold: "Order protein first:", rest: " Steak, chicken, salmon, shrimp. Double protein if small."),
        .init(bold: "Veggies as side:", rest: " Swap fries for steamed greens when possible."),
        .init(bold: "Skip bread/chips:", rest: " 300–600 empty calories that won't register."),
        .init(bold: "Sauces on side:", rest: " Creamy sauces add 200–400 kcal."),
        .init(bold: "Budget:", rest: " Restaurant meal = 800–1,200 kcal. Keep other meals lighter that day.")
    ]
}
