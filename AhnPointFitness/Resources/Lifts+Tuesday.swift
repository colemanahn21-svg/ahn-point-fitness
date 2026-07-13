import Foundation

extension Programme {
    // Tue Lift A can be either Trap Bar or Barbell Back Squat. The active
    // variant is selected from the Log tab (or the toggle on the Tuesday
    // card in Lifts) and stored in @AppStorage("tueLiftAVariant").
    static let tueLiftAVariants: [String: ExerciseDef] = [
        "Trap Bar Squat": ExerciseDef(
            "tue-a",
            "A. Trap Bar Squat (low handles)",
            ["4×5-7", "3-1-1-0", "120s"],
            "Use low handles for full ROM. Shifts ~30% of spinal compression to hips and arms vs back squat. More force output at the same %1RM. Match or exceed your back squat working weight — most lifters trap bar 10-15% more."
        ),
        "Barbell Back Squat": ExerciseDef(
            "tue-a",
            "A. Barbell Back Squat",
            ["4×5-7", "3-1-1-0", "120s"],
            "High-bar position, upright torso, full depth. Bigger axial spinal load than trap bar — brace hard, controlled eccentric, no bounce. Quads do more of the work; pair with the RDL that follows for a balanced posterior-chain hit."
        )
    ]

    static let tuesday = DayContent(
        day: .tue,
        title: "Tue · Legs",
        subtitle: "~90 min · Gym → Turf",
        tag: .abs,
        sections: [
            .mobilityPrimer(
                dividerTitle: "⬇ Mobility Primer · 8 min ⬇",
                label: "Warm-Up · Preps Hips + T-Spine for Squats + Rotational Work",
                items: [
                    .init("tue-mp1", "Leg Swings (front/back + side/side) · 10 each direction"),
                    .init("tue-mp2", "World's Greatest Stretch · 3/side"),
                    .init("tue-mp3", "90/90 Hip Switch · 8 transitions with 3s hold"),
                    .init("tue-mp4", "Band Glute Bridge (band above knees) · 2×15 (glute med activation)"),
                    .init("tue-mp5", "Band Monster Walk (10 steps each direction) · 2 rounds"),
                    .init("tue-mp6", "Band Pull-Apart (standing + rotate) · 2×10/side (thoracic + rear delt)"),
                    .init("tue-mp7", "Cossack Squat · 5/side with 2s pause at bottom"),
                    .init("tue-mp8", "Bodyweight Squat to Depth Hold · 2×5 with 2s pause")
                ]
            ),
            .groups([
                GroupBlock(label: "Power Primer · 4 min", labelColor: .orange, exercises: [
                    .init("tue-p1", "P1. Med Ball Rotational Slam (to floor)", ["3×5/side", "Max effort", "30s"],
                          "Athletic stance perpendicular to your slam target on the floor. Load hips, explosive rotation, slam ball diagonally down to floor as hard as possible. Same rotational power + hip-shoulder separation as a wall throw, no wall needed. 6–8 lb ball."),
                    .init("tue-p2", "P2. Half-Kneel Med Ball Overhead Slam", ["3×5/side", "Max effort", "30s"],
                          "Half-kneel on turf with ball overhead. Explosive forward-down slam into turf in front of you. Half-kneel eliminates leg drive and isolates thoracic-abdominal rotation that drives the X-factor. Switch knees each set. Ball stays where you slam it — no chasing. Same training effect as a shotput throw. 6–8 lb ball.")
                ]),
                GroupBlock(exercises: [
                    .init("tue-a", "A. Trap Bar Squat (low handles)", ["4×5-7", "3-1-1-0", "120s"],
                          "Use low handles for full ROM. Shifts ~30% of spinal compression to hips and arms vs back squat. More force output at the same %1RM. Match or exceed your back squat working weight — most lifters trap bar 10-15% more."),
                    .init("tue-b", "B. Romanian Deadlift", ["4×8-10", "3-1-1-0", "90s"],
                          "Primary posterior chain builder. Heavy eccentric for hamstrings."),
                    .init("tue-c", "C. Walking Lunges (DB)", ["3×10/leg", "2-0-1-0", "75s"],
                          "Unilateral quad/glute work. Addresses imbalances."),
                    .init("tue-d", "D. Leg Curl", ["3×10-12", "3-1-1-0", "60s"],
                          "Isolated knee-flexion hamstring work."),
                    .init("tue-e", "E. Leg Press (standard foot placement)", ["3×12-15", "3-1-1-0", "75s"],
                          "Quad-emphasis volume. Feet shoulder-width, lower on platform. Balances the trap bar's posterior-chain bias by hammering quads with zero spinal load."),
                    .init("tue-f", "F. Standing Calf Raise", ["4×12-15", "2-2-1-0", "45s"],
                          "Heavy loading, full stretch. 2s pause at bottom.")
                ])
            ]),
            .abCircuit(
                title: "⬇ Grab 1 DB + 1 Plate + 1 KB → Turf ⬇",
                groupLabel: "Ab Circuit · TURF · 2 Rounds · No rest between",
                items: [
                    .init("tue-e1", "E1. Plate Crunch (lying, knees bent)", ["15", "2-0-1-0"],
                          "Pure rectus abdominis flexion. Knees bent, feet flat = hip flexors stay neutral. Post-leg-day friendly."),
                    .init("tue-e2", "E2. KB Russian Twist (feet elevated)", ["20 total", "1-0-1-0"],
                          "KB at chest, feet off the floor, rotate side to side touching KB to turf. Oblique rotation + anti-gravity. Cable-free rotational work."),
                    .init("tue-e3", "E3. Plate Dead Bug", ["10/side", "2-1-2-0"],
                          "Hold plate at arm's length over chest. Alternate opposite arm/leg extensions. Anti-extension + contralateral coordination. Slow and controlled — hip flexors stay passive."),
                    .init("tue-e4", "E4. DB Woodchop (half-kneel, no cable)", ["10/side", "Explosive concentric"],
                          "Half-kneeling on turf, both hands on one DB held at hip. Swing DB up and across body like chopping wood. Rotational power without leaving the turf."),
                    .init("tue-e5", "E5. Side Plank + Hip Dip", ["10 dips/side", "Controlled"],
                          "Side plank position, dip hip toward floor, drive back up. Anti-lateral flexion + oblique burn."),
                    .init("tue-e6", "E6. KB Swing (hip hinge)", ["15", "Explosive"],
                          "Heart-rate spike station — the KB is already out. Powerful hip snap, arms relaxed, glutes finish the rep. Pushes the circuit into Zone 3 without loading tired quads. 60s rest → Round 2.")
                ]
            ),
            .saunaNote("🧖 SAUNA: 15 min infrared after stretching. Best sauna day of the week — flushes legs, elevates growth hormone."),
            .stretchBlocks(title: "⬇ Stretch · 15–20 min ⬇", blocks: [
                StretchBlock(label: "Post–Legs Stretching", stretches: [
                    .init("tue-s1", "Couch Stretch", ["60–90s/side"],
                          "Iliopsoas + rectus femoris. Most effective hip flexor stretch. Squats shorten hip flexors—this restores full extension. Squeeze glute to posteriorly tilt pelvis."),
                    .init("tue-s2", "Standing Quad Pull + Pelvic Tilt", ["45s/side"],
                          "Rectus femoris crosses hip and knee. Posterior tilt is critical—without it, stretch only reaches the vasti."),
                    .init("tue-s3", "Elevated Hamstring Stretch", ["60s/side"],
                          "Biceps femoris + semimembranosus. RDLs create peak eccentric tension at long lengths—returns muscle to resting length."),
                    .init("tue-s4", "Pigeon Pose", ["60–90s/side"],
                          "Piriformis, glute med, deep external rotators. Squats load these as stabilisers. If piriformis compresses sciatic nerve, you'll feel it—stretch now."),
                    .init("tue-s5", "90/90 Hip Transitions", ["8 reps slow"],
                          "Hip internal/external rotation. Squats demand sagittal stability but restrict rotational ROM."),
                    .init("tue-s6", "Frog Stretch", ["60–90s"],
                          "Adductor longus, brevis, magnus. Wide-stance pressing and lunges load adductors. Ease in gradually."),
                    .init("tue-s7", "Wall Calf (straight + bent knee)", ["40s/position/side"],
                          "Straight = gastrocnemius. Bent = soleus. Two positions non-negotiable—functionally different muscles."),
                    .init("tue-s8", "Supine Spinal Twist", ["45s/side"],
                          "Lumbar erectors, QL, obliques. Squats brace lumbar spine isometrically—this rotation decompresses.")
                ])
            ])
        ]
    )
}
