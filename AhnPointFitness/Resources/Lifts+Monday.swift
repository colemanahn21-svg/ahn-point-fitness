import Foundation

extension Programme {
    static let monday = DayContent(
        day: .mon,
        title: "Mon · Back + Chest",
        subtitle: "~75 min · Gym",
        tag: .cardio,
        sections: [
            .mobilityPrimer(
                dividerTitle: "⬇ Mobility Primer · 6 min ⬇",
                label: "Warm-Up · Preps Shoulders + T-Spine for Pressing/Pulling",
                items: [
                    .init("mon-mp1", "Cat-Cow · 10 slow reps"),
                    .init("mon-mp2", "Open Book (side-lying) · 8/side with 2s hold"),
                    .init("mon-mp3", "Band Pull-Apart · 2×20 (rear delts + scapular retraction)"),
                    .init("mon-mp4", "Band Face Pull (anchored door/rail) · 2×15 (rotator cuff prep)"),
                    .init("mon-mp5", "Band Dislocate (wide grip, overhead) · 2×10 (shoulder capsule)"),
                    .init("mon-mp6", "Scapular Push-Up · 2×10 (serratus activation)"),
                    .init("mon-mp7", "Band External Rotation · 2×12/side (teres minor + infraspinatus)")
                ]
            ),
            .groups([
                GroupBlock(label: "Superset A · No rest A1→A2 · 90s after pair", exercises: [
                    .init("mon-a1", "A1. Barbell Bench Press", ["4×6-8", "3-1-1-0", "→ A2"],
                          "Primary horizontal push. Heavy compound for chest mass. Antagonist paired with row — go straight to A2 with no rest; the pairing rests each muscle while keeping heart rate up."),
                    .init("mon-a2", "A2. Barbell Bent-Over Row", ["4×6-8", "3-1-1-0", "90s"],
                          "Primary horizontal pull. Balances pressing volume, builds thick lats and mid-back. Rest 90s after the pair, then back to A1.")
                ]),
                GroupBlock(label: "Superset B · No rest B1→B2 · 60s after pair", exercises: [
                    .init("mon-b1", "B1. Incline DB Press (30°)", ["3×8-10", "3-0-1-1", "→ B2"],
                          "Upper chest emphasis. Shifts load to clavicular head. Straight to B2, no rest."),
                    .init("mon-b2", "B2. Chest-Supported DB Row", ["3×8-10", "3-1-1-0", "60s"],
                          "Isolates lats/rhomboids without low-back fatigue. Rest 60s after the pair — RPE 7-8 volume work tolerates the density.")
                ]),
                GroupBlock(label: "Giant Set C · C1→C2→C3 no rest · 60s after round · 3 rounds", exercises: [
                    .init("mon-c1", "C1. Cable Fly (low-to-high)", ["3×12-15", "2-1-2-0", "→ C2"],
                          "Inner/upper chest isolation with constant cable tension. Straight to C2, no rest."),
                    .init("mon-c2", "C2. Straight-Arm Pulldown", ["3×12-15", "2-1-2-0", "→ C3"],
                          "Isolates lats without bicep. Teaches scapular depression. Straight to C3, no rest."),
                    .init("mon-c3", "C3. Face Pulls", ["3×15-20", "2-1-2-0", "60s"],
                          "Rear delt and external rotator health. Non-negotiable prehab. Closes the round — all three moves live at the cable area, so heart rate stays up with zero travel. 60s, back to C1.")
                ])
            ]),
            .cardioFinisher(
                title: "⬇ Cardio Finisher · Pick One ⬇",
                options: [
                    .init("mon-cd1", "Running", ["15-20 min", "8:30-9:30/mi", "Zone 2"]),
                    .init("mon-cd2", "Assault Bike", ["12-15 min", "55-65 RPM", "Zone 2"]),
                    .init("mon-cd3", "Stairmaster", ["12-15 min", "Lvl 6-8", "Zone 2"]),
                    .init("mon-cd4", "Incline Walk", ["15-20 min", "12-15%, 3.5 mph", "Zone 2"])
                ],
                note: "Upper body day = legs are fresh. Running is a great choice. Every week: add 4×30–45s pushes to Zone 3–4 with easy pace between — don't leave this in Zone 2."
            ),
            .stretchBlocks(title: "⬇ Stretch · 15–20 min ⬇", blocks: [
                StretchBlock(label: "Post–Back + Chest Stretching", stretches: [
                    .init("mon-s1", "Doorway Pec Stretch (90° + 135°)", ["45s/angle/side"],
                          "Two angles: 90° hits sternal fibres from flat bench; 135° hits clavicular from incline. Restores shoulder protraction/retraction balance."),
                    .init("mon-s2", "Supine Floor Angel", ["10 reps slow"],
                          "Pec minor, anterior delt, serratus. Floor gives feedback—if low back lifts off, pec minor is the limiter."),
                    .init("mon-s3", "Cat-Cow + Extended Hold", ["8 reps + 10s holds"],
                          "Thoracic erectors locked from bracing during bench/rows. Restores segmental flexion/extension."),
                    .init("mon-s4", "Thread the Needle", ["45s/side"],
                          "Thoracic rotation + lat stretch. Push/pull is sagittal-only—reclaims transverse plane ROM."),
                    .init("mon-s5", "Prayer Lat Stretch (kneeling)", ["45s × 2"],
                          "Kneel in front of a bench, couch, or box. Forearms flat on the surface, hands pressed together like prayer. Sit hips back toward heels and let chest sink toward the floor. Deep lat lengthening + teres major stretch without hanging — same tissue targets, anywhere."),
                    .init("mon-s6", "Foam Roller Thoracic Extension", ["60–90s"],
                          "Opens anterior chest wall, extends the kyphotic curve bench pressing reinforces."),
                    .init("mon-s7", "Cross-Body Posterior Delt", ["40s/side"],
                          "Posterior delt, infraspinatus. Tight from rows and face pulls."),
                    .init("mon-s8", "Child's Pose (wide knee, reach far)", ["60–90s"],
                          "Lats, teres, thoracolumbar fascia. Deep breathing shifts ANS toward parasympathetic recovery.")
                ])
            ])
        ]
    )
}
