import Foundation

extension Programme {
    static let thursday = DayContent(
        day: .thu,
        title: "Thu · Arms + Shoulders",
        subtitle: "~90 min · Gym → Cable Station",
        tag: .abs,
        sections: [
            .mobilityPrimer(
                dividerTitle: "⬇ Mobility Primer · 6 min ⬇",
                label: "Warm-Up · Preps Shoulders + Elbows for Pressing/Curling",
                items: [
                    .init("thu-mp1", "Shoulder CARs · 5/direction/side (capsule warm-up)"),
                    .init("thu-mp2", "Wall Slide (shoulder W to Y) · 2×10"),
                    .init("thu-mp3", "Band Dislocate (wide → narrow grip) · 2×10"),
                    .init("thu-mp4", "Band Pull-Apart · 2×15"),
                    .init("thu-mp5", "Band External Rotation · 2×12/side"),
                    .init("thu-mp6", "Band Overhead Press (very light) · 2×15 (grooves OHP pattern)"),
                    .init("thu-mp7", "Wrist Circles + Elbow Flex/Extend · 10 each")
                ]
            ),
            .groups([
                GroupBlock(label: "Superset A · No rest A1→A2 · 90s after pair", exercises: [
                    .init("thu-a1", "A1. Seated DB OHP", ["4×6-8", "3-0-1-0", "→ A2"],
                          "Primary shoulder compound. Seated removes leg drive. Straight to A2 with no rest — press and curl don't compete."),
                    .init("thu-a2", "A2. EZ-Bar Curl", ["3×6-8", "3-0-1-1", "90s"],
                          "Primary bicep mass builder. EZ-bar reduces wrist strain. Rest 90s after the pair.")
                ]),
                GroupBlock(label: "Superset B · No rest B1→B2 · 60s after pair", exercises: [
                    .init("thu-b1", "B1. Cable Lateral Raise", ["3×12-15", "2-1-2-0", "→ B2"],
                          "Medial delt width. Cables maintain constant tension. Straight to B2, no rest."),
                    .init("thu-b2", "B2. OH Tricep Extension", ["3×10-12", "2-1-2-0", "60s"],
                          "Long head of triceps in stretched position. Rest 60s after the pair.")
                ]),
                GroupBlock(label: "Superset C · No rest C1→C2 · 60s after pair", exercises: [
                    .init("thu-c1", "C1. Reverse Pec Deck", ["3×12-15", "2-1-2-0", "→ C2"],
                          "Rear delt isolation. Balances heavy pressing. Straight to C2, no rest."),
                    .init("thu-c2", "C2. Hammer Curl", ["3×10-12", "2-0-1-1", "60s"],
                          "Moved up from D2. Brachialis is fresher here — you can actually load these properly. Neutral grip after reverse pec deck is a smooth transition. Rest 60s after the pair.")
                ]),
                GroupBlock(label: "Superset D · No rest D1→D2 · 60s after pair", exercises: [
                    .init("thu-d1", "D1. Dip Machine / CG Bench", ["3×8-10", "3-0-1-0", "→ D2"],
                          "Compound tricep movement. Straight to D2, no rest."),
                    .init("thu-d2", "D2. Incline DB Curl", ["3×10-12", "3-0-1-1", "60s"],
                          "Finisher. Stretch-position exercise — works even when fatigued because the incline does the work. Deep stretch recruits long head regardless of how gassed you are. 25–30 lb is plenty here. Rest 60s after the pair.")
                ])
            ]),
            .abCircuit(
                title: "⬇ Ab Circuit at the Cable Station ⬇",
                groupLabel: "Ab Circuit · CABLE STATION · 2 Rounds · No rest between",
                items: [
                    .init("thu-e1", "E1. Cable Crunch (kneeling)", ["12-15", "2-1-2-0"],
                          "Kneeling at cable stack, rope attachment high, crunch down pulling elbows to knees. Direct rectus flexion under constant load — the strongest loaded ab exercise available."),
                    .init("thu-e2", "E2. Cable Woodchop (high-to-low)", ["10/side", "2-0-1-0"],
                          "Rotational power chain. Explosive on the concentric, controlled return. Trains the same kinematic sequence as a golf swing — lead hip pull + trail side rotation."),
                    .init("thu-e3", "E3. Cable Pallof Press (standing)", ["12/side", "2-2-1-0"],
                          "Standing perpendicular to cable, handle at sternum, press straight out and hold 2s. Anti-rotation isometric. Core has to resist the pull — no rep cheating possible."),
                    .init("thu-e4", "E4. Cable Reverse Woodchop (low-to-high)", ["10/side", "2-0-1-0"],
                          "Cable low, explode up and across body to opposite shoulder. Opposite direction from E2. Hits the rotational chain from the other angle — critical for balanced oblique development."),
                    .init("thu-e5", "E5. Cable Side Bend (standing)", ["12/side", "2-1-1-0"],
                          "Stand sideways to cable, handle at hip height, lean away against resistance. Direct oblique isolation under constant tension."),
                    .init("thu-e6", "E6. Bike Sprint or Jump Rope", ["30s", "Max effort"],
                          "Heart-rate spike station. 30 seconds all-out on the nearest bike (or jump rope by the cable station). Legs are fresh on arm day — this is what pushes the circuit into Zone 3–4. 60s rest → Round 2.")
                ]
            ),
            .cardioFinisher(
                title: "⬇ Cardio Finisher · Intervals · Pick One ⬇",
                options: [
                    .init("thu-cd1", "Assault Bike Intervals", ["10-12 min", "30s hard / 30s easy", "Zone 3-4"]),
                    .init("thu-cd2", "Rowing Intervals", ["10-12 min", "40s hard / 40s easy", "Zone 3-4"]),
                    .init("thu-cd3", "Incline Treadmill Pushes", ["12 min", "1 min @ 12% brisk / 1 min easy", "Zone 3"])
                ],
                note: "Arms are fried but legs are fresh — bike/row intervals raise heart rate without stealing from Friday. Cap it at 12 min."
            ),
            .stretchBlocks(title: "⬇ Stretch · 15–20 min ⬇", blocks: [
                StretchBlock(label: "Post–Arms + Shoulders Stretching", stretches: [
                    .init("thu-s1", "Overhead Tricep Stretch", ["45s/side"],
                          "Long head crosses shoulder joint. Overhead extensions train it shortened—this restores length and improves overhead flexion ROM."),
                    .init("thu-s2", "Wall Bicep Stretch", ["45s/side"],
                          "Both bicep heads + anterior delt. Combines shoulder extension + elbow extension + supination for a complete stretch. Counteracts all curling."),
                    .init("thu-s3", "Shoulder CARs", ["5/direction/side"],
                          "Controlled Articular Rotations. Gold standard for maintaining usable ROM. Signals to nervous system that full range is safe after heavy pressing."),
                    .init("thu-s4", "Forearm Flexor Stretch", ["30s/side"],
                          "Flexor carpi radialis/ulnaris. Chronic tightness → medial epicondylitis (golfer's elbow). Essential given your golf habit."),
                    .init("thu-s5", "Forearm Extensor Stretch", ["30s/side"],
                          "Extensor carpi radialis/ulnaris. Tightness causes lateral epicondylitis (tennis elbow)."),
                    .init("thu-s6", "Doorway Lat + Shoulder Hang", ["45s/side"],
                          "Overhead pressing compresses subacromial space—traction stretch opens it. Critical for long-term shoulder health."),
                    .init("thu-s7", "Upper Trap + Levator Scap Release", ["40s/side"],
                          "Lateral raises elevate scapula repeatedly. These muscles hold tension reflexively—release before they cause cervicogenic headaches."),
                    .init("thu-s8", "Prone Shoulder Extension", ["45s"],
                          "Lying face-down, hands clasped behind. Opens entire anterior chain. After pressing and curling all session, this is the reset position.")
                ])
            ])
        ]
    )
}
