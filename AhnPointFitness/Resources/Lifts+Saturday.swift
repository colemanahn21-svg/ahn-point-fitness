import Foundation

extension Programme {
    static let saturday = DayContent(
        day: .sat,
        title: "Sat · Athletic Conditioning + Abs",
        subtitle: "70 min · Complete Athlete",
        tag: .abs,
        sections: [
            .warmupBlock(label: "A. Dynamic Warm-Up (6 min)", items: [
                .init("sat-w1", "High Knees · 20 yd"),
                .init("sat-w2", "Butt Kicks · 20 yd"),
                .init("sat-w3", "Lateral Shuffle · 20 yd each direction"),
                .init("sat-w4", "Carioca · 20 yd each direction"),
                .init("sat-w5", "A-Skip · 20 yd"),
                .init("sat-w6", "Spiderman Lunge + Reach · 8/side")
            ]),
            .groups([
                GroupBlock(label: "B. Plyometrics (8 min)", labelColor: .orange, exercises: [
                    .init("sat-b1", "B1. Box Jump (step down)", ["3×5", "Explosive", "45s"],
                          "Concentric-only power. Step down — no eccentric impact before Monday. Full hip extension at top."),
                    .init("sat-b2", "B2. Lateral Bound (stick 2s)", ["3×5/side", "Explosive", "45s"],
                          "Single-leg lateral power. The dodge-and-cut pattern from lacrosse. Hold the landing."),
                    .init("sat-b3", "B3. Med Ball Rotational Slam", ["3×6/side", "Explosive", "45s"],
                          "Athletic stance, slam ball diagonally down to floor. Rotate through hips and torso explosively. Shot and pass mechanic — no wall needed.")
                ])
            ]),
            .conditioningCircuit(
                title: "⬇ Conditioning Circuit · 16 min ⬇",
                heading: "3 Rounds — no rest between exercises, 90s rest between rounds",
                body: "250m Row → 10 KB Goblet Squats → 10 KB Swings → 10 Push-Ups → 30s Plank → 250m Row",
                footer: "~4 min work + 90s rest per round. HR: 140–160 bpm. Submaximal — short sentences, not a conversation."
            ),
            .groups([
                GroupBlock(label: "D. Loaded Carry Complex (8 min)", exercises: [
                    .init("sat-d1", "D1. Farmer's Carry (heavy DBs)", ["2×40 yd", "45s rest"],
                          "Heaviest you can hold. Grip, core, traps. Walk fast, stay tall."),
                    .init("sat-d2", "D2. Overhead Carry (single DB/KB)", ["2×30 yd/side", "45s rest"],
                          "One arm locked overhead. Shoulder stability, obliques, thoracic extension."),
                    .init("sat-d3", "D3. Bear Crawl", ["2×20 yd", "45s rest"],
                          "Forward + backward. Knees 2\" off ground. No machine can replicate this.")
                ])
            ]),
            .abCircuit(
                title: "⬇ Ab Circuit on Turf (stay with KB/DB/plate) ⬇",
                groupLabel: "E. Ab Circuit · TURF · 2 Rounds · No rest between",
                items: [
                    .init("sat-e1", "E1. KB Halo", ["8/direction", "Controlled"],
                          "Hold KB by horns at chest, circle it around your head slowly. Anti-extension + shoulder stability + oblique bracing. Great activation move that sets up the rest of the circuit."),
                    .init("sat-e2", "E2. DB Russian Twist (feet elevated)", ["20 total", "Controlled"],
                          "Feet off floor, DB at chest, rotate side to side. Oblique + anti-gravity demand."),
                    .init("sat-e3", "E3. Side Plank + KB Pull-Through", ["8/side", "Controlled"],
                          "Side plank on forearm, feet stacked. Place KB in front of chest. Reach top arm under body, drag KB across to other side, then back. Hips stay UP — flat line from feet to shoulder. Hits obliques, QL, glute med, plus anti-rotation under load. Self-limiting: if your hips drop, you stop."),
                    .init("sat-e4", "E4. Plate Sit-Up + Overhead Press", ["12-15", "2-0-1-0"],
                          "Sit-up with plate on chest, press plate overhead at top. Full rectus flexion + anterior chain tie-in."),
                    .init("sat-e5", "E5. Suitcase Hold (heavy DB)", ["30s/side", "Brace"],
                          "One heavy DB at your side, stand tall, brace everything. Anti-lateral flexion isometric. 60s rest → Round 2.")
                ]
            ),
            .saunaNote("🧖 SAUNA: 15 min infrared after mobility flow. Heat acclimation improves plasma volume → directly supports VO2max goal."),
            .mobility(title: "⬇ Mobility Flow · Weekly Reset · 15 min ⬇", block:
                MobilityBlock(label: "E. Mobility Flow", items: [
                    .init("sat-m1", "World's Greatest Stretch · 5/side slow"),
                    .init("sat-m2", "90/90 Hip Switch + Hold · 8 transitions + 15s holds"),
                    .init("sat-m3", "Couch Stretch · 90s/side"),
                    .init("sat-m4", "Pigeon Pose · 90s/side"),
                    .init("sat-m5", "Shoulder CARs · 5/direction/side"),
                    .init("sat-m6", "Foam Roller Thoracic Extension · 2 min"),
                    .init("sat-m7", "Supine Spinal Twist · 60s/side"),
                    .init("sat-m8", "Child's Pose · 2 min (4-count in, 6-count out)")
                ])
            )
        ]
    )
}
