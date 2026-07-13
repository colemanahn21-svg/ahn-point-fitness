import Foundation

extension Programme {
    static let sunday = DayContent(
        day: .sun,
        title: "Sun · Rest + Full-Body Flexibility",
        subtitle: "30–45 min · Weekly mobility reset",
        tag: .rest,
        sections: [
            .infoBlock(title: "Why This Matters",
                       body: "No lifting. But flexibility is the fifth pillar — and it directly supports driver swing speed through rotational ROM. A full-body flexibility session once a week builds on the daily post-lift stretches without adding eccentric stress. Still priorities: Sleep in (9:00–9:30a wake). Rest-day nutrition (~1,850 kcal). Hydrate 100+ oz. Full supplement stack."),
            .stretchBlocks(title: "⬇ Full-Body Flexibility · 30–45 min ⬇", blocks: [
                StretchBlock(label: "Block 1 · Thoracic + Shoulders (8 min)", stretches: [
                    .init("sun-s1", "Open Book (side-lying)", ["8 reps/side", "3s hold top"],
                          "Thoracic rotation in a closed-chain position. Lie on side, knees bent, top arm sweeps across chest and opens toward ceiling. Critical for golf swing rotation — most amateurs are stuck at 80° shoulder turn."),
                    .init("sun-s2", "Foam Roller T-Spine Extension", ["2 min"],
                          "Roller at mid-back, arms overhead. Undoes the week of kyphotic loading from pressing. Direct driver of backswing ROM."),
                    .init("sun-s3", "Shoulder CARs", ["5/direction/side"],
                          "Controlled Articular Rotations — full shoulder circles. Weekly reset for usable overhead ROM."),
                    .init("sun-s4", "Prone I-Y-T-W", ["8 reps each letter"],
                          "Lying face-down, form each letter with arms. Activates and lengthens lower traps, rear delts, rhomboids — postural muscles that get dominated by bigger prime movers all week.")
                ]),
                StretchBlock(label: "Block 2 · Hips + Lower Body (12 min)", stretches: [
                    .init("sun-s5", "World's Greatest Stretch", ["5/side, slow"],
                          "Lunge, rotate, reach. Hip flexors, thoracic rotation, hamstrings, adductors in one movement. The single most efficient full-chain stretch you can do."),
                    .init("sun-s6", "Deep Squat Hold (supported if needed)", ["2 min"],
                          "Heels flat, hips below knees. Hold onto a pole if you can't sit in the bottom without falling back. Restores ankle dorsiflexion, hip flexion, and adductor length simultaneously. Builds the base for squat depth."),
                    .init("sun-s7", "Couch Stretch", ["90s/side"],
                          "Rear foot elevated, front leg lunge. Deepest iliopsoas stretch available. Squeeze glute hard to posteriorly tilt pelvis — critical."),
                    .init("sun-s8", "Pigeon Pose", ["90s/side"],
                          "Piriformis, glute med, deep external rotators. Week of squatting and rotational work compresses these."),
                    .init("sun-s9", "90/90 Hip Switch + Hold", ["10 transitions + 20s holds"],
                          "Hip internal and external rotation — both critical for golf swing. Hold the end range positions to build active flexibility, not just passive stretch."),
                    .init("sun-s10", "Frog Stretch", ["90s"],
                          "Hands and knees, knees spread wide, rock back gently. Deep adductor release.")
                ]),
                StretchBlock(label: "Block 3 · Posterior Chain (8 min)", stretches: [
                    .init("sun-s11", "Standing Forward Fold + Sway", ["90s"],
                          "Feet hip-width, hinge forward, let head and arms hang heavy. Gently sway side to side. Full posterior chain decompression — hamstrings, calves, erectors."),
                    .init("sun-s12", "Elevated Hamstring Stretch", ["60s/side"],
                          "Foot on couch/bench, hinge forward with flat back. Biceps femoris + semitendinosus at full length."),
                    .init("sun-s13", "Wall Calf (straight + bent knee)", ["45s/position/side"],
                          "Straight = gastroc. Bent = soleus. Both loaded from the week's squatting and walking. Tight calves restrict ankle dorsiflexion, which limits squat depth."),
                    .init("sun-s14", "Supine Spinal Twist", ["60s/side"],
                          "Lumbar erectors, QL, obliques. Full decompression before the new training week.")
                ]),
                StretchBlock(label: "Block 4 · Decompression + Breathing (7 min)", stretches: [
                    .init("sun-s15", "Prayer Lat Stretch (kneeling)", ["45s × 3"],
                          "Kneel in front of a couch or bed. Forearms flat on the surface, hands pressed together in prayer. Sit hips back toward heels and let chest sink. Deep lat + teres major stretch, works from anywhere. Golf swing benefit: better turn from a lengthened lat chain."),
                    .init("sun-s16", "Child's Pose (wide knee)", ["90s"],
                          "Lats, teres, thoracolumbar fascia. Wide knees allow the torso to sink deeper."),
                    .init("sun-s17", "Legs-Up-the-Wall", ["3–5 min"],
                          "Lie on back, legs vertical against wall. Venous return, lymphatic drainage, parasympathetic activation. Do this while scrolling your phone — zero effort, high return."),
                    .init("sun-s18", "Box Breathing", ["5 min · 4-4-4-4"],
                          "4 sec inhale, 4 sec hold, 4 sec exhale, 4 sec hold. Directly stimulates the vagus nerve and drives HRV recovery overnight. This is the single biggest overnight recovery booster available.")
                ])
            ]),
            .infoBlock(title: "Optional Add-Ons",
                       body: "Walk: 20 min outdoors for sunlight and circadian rhythm support. Speed calibration (optional): If you go to the range, hit 20 max-effort drives with a launch monitor. No swing thoughts except \"swing as hard as you possibly can without falling over.\" Teaches your nervous system that max speed is allowed.")
        ]
    )
}
