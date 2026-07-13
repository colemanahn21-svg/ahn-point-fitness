import Foundation

extension Programme {
    static let friday = DayContent(
        day: .fri,
        title: "Fri · Athletic Upper + Conditioning",
        subtitle: "60 min · Power + HIFT",
        tag: .cardio,
        sections: [
            .mobilityPrimer(
                dividerTitle: "⬇ Mobility Primer · 6 min ⬇",
                label: "Warm-Up · Preps Shoulders + T-Spine for Explosive Work",
                items: [
                    .init("fri-mp1", "Cat-Cow · 10 slow reps"),
                    .init("fri-mp2", "Open Book (side-lying) · 8/side with 2s hold"),
                    .init("fri-mp3", "Push-Up + T-Spine Rotation · 5/side"),
                    .init("fri-mp4", "Band Pull-Apart (fast tempo) · 2×20 (priming rear delts for explosive pulling)"),
                    .init("fri-mp5", "Band Dislocate · 2×10 (shoulder capsule for push press)"),
                    .init("fri-mp6", "Band External Rotation · 2×12/side"),
                    .init("fri-mp7", "Jumping Jacks · 45s (elevate HR before explosive work)")
                ]
            ),
            .groups([
                GroupBlock(label: "A. Power Primer", labelColor: .orange, exercises: [
                    .init("fri-a1", "A1. Med Ball Supine Chest Throw", ["2×8", "Explosive", "30s"],
                          "Lie on your back, hold ball at chest. Explosively press ball straight up, catch it, immediately reload and repeat. Same plyometric horizontal push as a wall chest pass — no wall needed, ball comes right back to you. Lacrosse passing power. 6–8 lb ball."),
                    .init("fri-a2", "A2. Explosive Pull-Up", ["2×5", "Explosive", "30s"],
                          "Pull hard enough to briefly release at top. Lat power — the engine behind every check and shot.")
                ]),
                GroupBlock(label: "Superset B — Heavy Functional", exercises: [
                    .init("fri-b1", "B1. SA DB Row (staggered stance)", ["3×8/side", "2-0-1-1", "75s"],
                          "Standing, no bench. Anti-rotation under heavy load. 80–100 lb."),
                    .init("fri-b2", "B2. SA DB Push Press (standing)", ["3×6-8/side", "Explode, 3s down", "75s"],
                          "Full kinetic chain, ground to overhead. Single-arm = massive anti-lateral flexion. 50–70 lb.")
                ]),
                GroupBlock(label: "Superset C — Landmine", exercises: [
                    .init("fri-c1", "C1. Landmine Row (single arm)", ["3×10/side", "2-1-1-0", "60s"],
                          "Standing hinge loads posterior chain isometrically while you row — full-body integration."),
                    .init("fri-c2", "C2. Landmine Press (half-kneel)", ["3×10/side", "2-0-1-0", "60s"],
                          "Half-kneeling eliminates compensation. Arced path is shoulder-friendly.")
                ]),
                GroupBlock(label: "D. Cable Tri-Set — No rest between", exercises: [
                    .init("fri-d1", "D1. Cable Face Pull", ["2×15", "2-1-2-0"],
                          "Posterior shoulder health."),
                    .init("fri-d2", "D2. Cable Pallof Press", ["2×10/side", "2-2-1-0"],
                          "Anti-rotation core."),
                    .init("fri-d3", "D3. Cable Chop (high-to-low)", ["2×10/side", "2-0-1-0"],
                          "Rotational power. All 3 planes in under 5 min. 60s rest after all three → repeat.")
                ])
            ]),
            .hiftFinisher(
                title: "⬇ HIFT Finisher · 10 min ⬇",
                heading: "4 Rounds — 60s rest between rounds",
                body: "10 KB Swings (heaviest) → 8 Push-Ups → 6 Pull-Ups → 200m Row or 15-cal Assault Bike",
                footer: "Target: ~90s work per round. HR to Zone 3–4 (150–170 bpm) during work. Far more effective than steady walking for VO2max."
            ),
            .stretchBlocks(title: "⬇ Stretch · 15–20 min ⬇", blocks: [
                StretchBlock(label: "Post–Athletic Upper Stretching", stretches: [
                    .init("fri-s1", "Puppy Pose", ["60–90s"], "Deep lat stretch after explosive pulling."),
                    .init("fri-s2", "Supine Floor Angel", ["10 reps slow"], "Pec minor and anterior delt after explosive push-ups and pressing."),
                    .init("fri-s3", "Cat-Cow + Extended Hold", ["8 reps + 10s holds"], "Thoracic mobility after rowing and overhead work."),
                    .init("fri-s4", "Thread the Needle", ["45s/side"], "Thoracic rotation — critical after cable chops."),
                    .init("fri-s5", "Prayer Lat Stretch (kneeling)", ["45s × 2"],
                          "Kneel in front of a bench. Forearms flat, hands in prayer. Sit hips back and chest drops. Lengthens the lats fully after pull-ups and rows — deeper stretch than a dead hang and you can do it anywhere."),
                    .init("fri-s6", "Upper Trap + Levator Scap", ["40s/side"], "Push press and rowing elevate the scapula — release it."),
                    .init("fri-s7", "Cross-Body Posterior Delt", ["40s/side"], "Tight from rows and face pulls."),
                    .init("fri-s8", "Child's Pose (wide knee)", ["60–90s"], "Parasympathetic wind-down.")
                ])
            ])
        ]
    )
}
