import Foundation

struct SleepRow: Identifiable {
    let id = UUID()
    let day: String
    let bed: String
    let wake: String
    let hrs: String
    let isSocial: Bool
}

enum SleepContent {
    static let schedule: [SleepRow] = [
        .init(day: "Sun", bed: "12:30a", wake: "8:30a", hrs: "8h", isSocial: false),
        .init(day: "Mon", bed: "12:30a", wake: "8:30a", hrs: "8h", isSocial: false),
        .init(day: "Tue", bed: "12:30a", wake: "8:30a", hrs: "8h", isSocial: false),
        .init(day: "Wed", bed: "12:30a", wake: "8:30a", hrs: "8h", isSocial: false),
        .init(day: "Thu", bed: "12:30a", wake: "8:30a", hrs: "8h", isSocial: false),
        .init(day: "Fri", bed: "1:00a", wake: "9:15a", hrs: "8h", isSocial: true),
        .init(day: "Sat", bed: "1:15a", wake: "9:15a", hrs: "8h", isSocial: true)
    ]

    static let whyItMatters: [InfoParagraph] = [
        .init(segments: [
            .text("Your data: "),
            .bold("<5.5 hrs = 31% recovery"),
            .text(". "),
            .bold("7.5+ hrs = 67% recovery"),
            .text(". Moving bedtime from 1:30→12:30 AM should lift HRV 8–15 ms in 2–3 weeks.")
        ])
    ]

    static let windDown: [MealDef] = [
        .init("w-1", "9:30p", "⛔ Food Cutoff", "Water and herbal tea only. Reduces resting HR, improves deep sleep.", nil),
        .init("w-2", "10:00p", "Magnesium + L-Theanine", "400mg mag glycinate + 200–400mg L-theanine.", nil),
        .init("w-3", "10:30p", "Melatonin", "0.5–1mg only. Low dose mimics natural production. Never exceed 1mg.", nil),
        .init("w-4", "11:30p", "Screens Off", "Read, stretch, or low-light activity.", nil),
        .init("w-5", "12:15a", "Lights Out", "Target: asleep by 12:30 AM.", nil)
    ]

    static let morningSupps: [SupplementDef] = [
        .init("m-1", "9:00a", "AG1 + Orange Juice", "1 scoop + 4–6 oz OJ", "Micronutrient base. OJ aids iron/B-vitamin absorption."),
        .init("m-2", "9:00a", "Arrae Protein + Electrolytes", "1 scoop in water", "Protein + hydration."),
        .init("m-3", "9:00a", "Thorne Creatine", "5g (in Arrae drink)", "Muscle retention, cell hydration. Daily — never skip."),
        .init("m-4", "9:00a", "Thorne Glutamine", "5g (in Arrae drink)", "Gut health, immune support, recovery."),
        .init("m-5", "9:15a", "Vitamin D3", "3,000–5,000 IU", "Take with eggs (fat-soluble). Immune, mood, testosterone."),
        .init("m-6", "9:15a", "Fish Oil (Omega-3)", "2–3g EPA+DHA", "Anti-inflammatory, HRV support. Take with fat."),
        .init("m-7", "9:15a", "Blissphora", "Per label", "Gut-brain axis, mood regulation, stress resilience.")
    ]

    static let caffeineSupps: [SupplementDef] = [
        .init("c-1", "8:45a", "Coffee", "1–2 cups",
              "Your caffeine source for the day. Within the first hour of waking. Black or minimal creamer. No second dose pre-workout — morning coffee is sufficient and keeps caffeine far from bedtime for HRV protection.")
    ]

    static let nightSupps: [SupplementDef] = [
        .init("n-1", "10:00p", "Magnesium Glycinate", "400mg", "Deep sleep, muscle relaxation, HRV support."),
        .init("n-2", "10:00p", "L-Theanine", "200–400mg", "Alpha brain waves, calm without sedation. Pairs with mag."),
        .init("n-3", "10:30p", "Melatonin", "0.5–1mg (LOW dose)", "Sleep onset timing. Start at 0.5mg. Never exceed 1mg.")
    ]

    static let socialNightsInfo = (
        title: "Social Nights",
        body: "Take the full nighttime stack even if you get home late. Pop mag + L-theanine + melatonin as soon as you're home. It will improve whatever sleep you get."
    )
}
