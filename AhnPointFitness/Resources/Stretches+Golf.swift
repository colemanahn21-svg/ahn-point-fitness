import Foundation

/// Golf rotational mobility. Built around one finding: thoracic rotation range
/// drops sharply from a flexed posture and leaks into side-bend when it does,
/// so every session opens the spine into extension and resets rib position
/// BEFORE asking it to rotate. Order is the programme.
extension StretchLibrary {
    enum Golf {

        static let dailyRotationRestore = StretchRoutine(
            id: "golf.daily",
            name: "Daily Rotation Restore",
            subtitle: "Thoracic + hips · do this one every day",
            focus: .golf,
            phases: [
                StretchPhase(id: "golf.daily.p1", label: "Phase 1 · Open the Spine", steps: [
                    StretchStep(
                        id: "g1", name: "Peanut Extension · Low Ribs (T8–T10)",
                        detail: "Peanut straddling the spine on the muscle, never on the bone. 5 small crunches to pin the segment, then reach both arms overhead and try to touch thumbs to the floor. Segmental — it forces extension at THIS level instead of letting your one mobile segment do all the work.",
                        chips: ["45s"]),
                    StretchStep(
                        id: "g2", name: "Peanut Extension · Mid (T6–T8)",
                        detail: "Move the peanut up one segment. Same 5 crunches, same overhead reach. If a level feels blocked, spend an extra breath there — that's the one costing you rotation.",
                        chips: ["45s"]),
                    StretchStep(
                        id: "g3", name: "Peanut Extension · Upper (T4–T6)",
                        detail: "Final position, between the shoulder blades. Keep the hips down; if they lift you're extending through the low back instead of the mid-back.",
                        chips: ["45s"]),
                    StretchStep(
                        id: "g4", name: "Roller Extension + Full Exhale",
                        detail: "Roller across the mid-back, hands supporting the head, hips down. Exhale fully at the bottom of each rep and pause 2s with the air out. Extending on a held inhale just flares the ribs — the exhale is what moves the joint.",
                        chips: ["60s"]),
                    StretchStep(
                        id: "g5", name: "Supine 90/90 Exhale Breathing",
                        detail: "Feet on a wall or chair, hips and knees at 90°, low back FLAT. In through the nose 4s, out through pursed lips 8s, pause 3s with the air fully out. Resets rib position from flared to stacked — your ribs are the rotation hardware, and this is the piece most people skip.",
                        chips: ["120s"]),
                ]),
                StretchPhase(id: "golf.daily.p2", label: "Phase 2 · Rotate What You Opened", steps: [
                    StretchStep(
                        id: "g6", name: "Bench Sink (lat + t-spine)",
                        detail: "Kneel, elbows on a couch or coffee table, hips back over the heels. Let the chest sink and the armpits open. Exhale deeper on each breath. Given three lat exercises on your Monday, this one is not optional.",
                        chips: ["90s"]),
                    StretchStep(
                        id: "g7", name: "Heel-Sit Reach-Back",
                        detail: "Sit back on the heels, chest to thighs, one hand behind the head. Drive the elbow from floor to ceiling. Hips stay glued to the heels — that lockout is the whole point, it leaves the rotation nowhere to go but the t-spine.",
                        chips: ["45s/side"]),
                    StretchStep(
                        id: "g8", name: "Open Book · Pelvis Pinned",
                        detail: "Side-lying, top knee bent 90° on a pillow and it does NOT move. Rotate the top arm and chest open toward the floor behind you. Exhale hard at end range and sink another inch. The pinned knee stops the lumbar spine donating rotation.",
                        chips: ["45s/side"]),
                ]),
                StretchPhase(id: "golf.daily.p3", label: "Phase 3 · Hips, Both Directions", steps: [
                    StretchStep(
                        id: "g9", name: "90/90 Hip Switches",
                        detail: "Slow switches, 2s pause at each end, no hands. Front leg is external rotation, back leg is internal rotation — one position covering both halves of your restriction.",
                        chips: ["60s"]),
                    StretchStep(
                        id: "g10", name: "90/90 PAIL/RAIL",
                        detail: "Hinge over the front leg to honest end range, hold 30s. PAIL: press the shin DOWN into the floor at 60–70% for 10s. RAIL: reverse it, try to lift that knee OFF the floor at 60–70% for 10s. Relax and sink deeper. End-range isometrics are what make new range survive a swing at speed.",
                        chips: ["90s/side"]),
                    StretchStep(
                        id: "g11", name: "Half-Kneeling Hip Flexor + Overhead Reach",
                        detail: "Squeeze the down-side glute and TUCK the pelvis first, then reach the same-side arm overhead and side-bend away. If you're arching your low back to feel it, you've lost the rep. Hip flexor + lat + side-bend in one position.",
                        chips: ["45s/side"]),
                ]),
                StretchPhase(id: "golf.daily.p4", label: "Phase 4 · Own It", steps: [
                    StretchStep(
                        id: "g12", name: "Standing Club Rotations",
                        detail: "Club across the shoulders, golf posture, progressively larger turns, exhaling into each one. Never end a mobility session passive — rotate through the new range actively so the nervous system files it as usable.",
                        chips: ["60s"]),
                ]),
            ])

        static let weeklyAddOns = StretchRoutine(
            id: "golf.weekly",
            name: "3×/Week Add-Ons",
            subtitle: "Run after the daily sequence",
            focus: .golf,
            phases: [
                StretchPhase(id: "golf.weekly.p1", label: "Deep Work", steps: [
                    StretchStep(
                        id: "gw1", name: "Bretzel",
                        detail: "Side-lying, top knee pinned down by the opposite hand, reach back and grab the bottom ankle pulling heel to glute, rotate the chest to the ceiling. Trail-hip quad length and t-spine rotation at once — the best single position you own.",
                        chips: ["40s/side"]),
                    StretchStep(
                        id: "gw2", name: "Thread the Needle",
                        detail: "Adds scapular glide to the rotation. Reach far and let the shoulder settle rather than forcing the floor.",
                        chips: ["45s/side"]),
                    StretchStep(
                        id: "gw3", name: "Side-Lying Rib Expansion Breathing",
                        detail: "Lie on your side, top arm overhead. Inhale into the UP-side ribs only. Directly mobilises the costovertebral joints — the actual hardware of thoracic rotation.",
                        chips: ["60s/side"]),
                    StretchStep(
                        id: "gw4", name: "Doorway Pec · 90° Elbow",
                        detail: "Sternal fibres. Your bench and dip volume shortens these, which pulls you into flexion, which kills rotation.",
                        chips: ["30s/side"]),
                    StretchStep(
                        id: "gw5", name: "Doorway Pec · 135° Elbow",
                        detail: "Clavicular fibres. Different angle, different fibre direction — one height does not cover both.",
                        chips: ["30s/side"]),
                    StretchStep(
                        id: "gw6", name: "Adductor Rock-Back",
                        detail: "All fours, one leg straight out to the side, foot flat. Rock the hips back toward the heel of the down leg. Lead adductor length is a quiet limiter on clearing the hips.",
                        chips: ["45s/side"]),
                    StretchStep(
                        id: "gw7", name: "Cervical Rotation",
                        detail: "Chin level, no tilting. The head has to stay while the shoulders turn — a stiff neck silently shortens your backswing.",
                        chips: ["30s/side"]),
                ]),
            ])

        static let preRound = StretchRoutine(
            id: "golf.preround",
            name: "Pre-Round Dynamic",
            subtitle: "At the course · no static holds",
            focus: .preRound,
            phases: [
                StretchPhase(id: "golf.preround.p1", label: "Move, Don't Hold", steps: [
                    StretchStep(
                        id: "gp1", name: "Club-Across-Shoulders Rotations",
                        detail: "Golf posture, progressively larger each rep. Static stretching before a round measured out at −4.2% clubhead speed and −31% accuracy — this block stays moving for a reason.",
                        chips: ["45s"]),
                    StretchStep(
                        id: "gp2", name: "Leg Swings · Front-Back",
                        detail: "Relaxed leg, let it swing rather than forcing height. Hips open up without costing you power.",
                        chips: ["30s/side"]),
                    StretchStep(
                        id: "gp3", name: "Leg Swings · Lateral",
                        detail: "Adductors and abductors, the plane your first tee shot actually loads.",
                        chips: ["30s/side"]),
                    StretchStep(
                        id: "gp4", name: "Walking Spiderman + Reach",
                        detail: "Lunge, hand inside the front foot, reach the other arm to the sky. Hips and t-spine together, moving — no holds over 3s.",
                        chips: ["60s"]),
                    StretchStep(
                        id: "gp5", name: "Hip CARs",
                        detail: "Slow controlled circles at the biggest range you own. Primes the joint capsule without sedating anything.",
                        chips: ["45s/side"]),
                    StretchStep(
                        id: "gp6", name: "Ramped Swings · 50 → 90%",
                        detail: "Build speed gradually. Dynamic warm-ups are the version that measurably RAISES clubhead speed.",
                        chips: ["90s"]),
                    StretchStep(
                        id: "gp7", name: "Left-Handed Swings",
                        detail: "Counter-rotation. Restores side-to-side symmetry and primes the direction you're most restricted in.",
                        chips: ["45s"]),
                ]),
            ])
    }
}
