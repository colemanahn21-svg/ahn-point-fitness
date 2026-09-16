import Foundation

/// Golf rotational mobility, built as a flow rather than a checklist.
///
/// The body only moves in one direction — floor, side, seated, all fours,
/// kneeling, standing — and every position is entered on an exhale and eased
/// on the inhale, so rotation is trained by rotating rather than by holding
/// still. Order still carries the programme's central claim: the thoracic
/// spine is opened into extension and the ribs are reset BEFORE anything asks
/// it to rotate.
extension StretchLibrary {
    enum Golf {

        static let rotationFlow = StretchRoutine(
            id: "golf.flow",
            name: "Golf Rotation Flow",
            subtitle: "Floor to standing · breath-led · every day",
            focus: .golf,
            phases: [
                StretchPhase(id: "golf.flow.p1", label: "Floor · Open", steps: [
                    StretchStep(
                        id: "gf1", name: "Peanut Climb (T10 → T4)",
                        detail: "One continuous position. Lie back over the peanut with the arms overhead, arch over it on each exhale and let the ribs drop, and after four breaths slide the peanut up one level. Low ribs, mid, upper. Segmental — it forces extension at each level instead of letting the one mobile segment do all the work.",
                        chips: ["2 min", "≈ 16 breaths · up a level every 4"]),
                    StretchStep(
                        id: "gf2", name: "Rib Reset (feet up)",
                        detail: "Stay on your back, feet up on the couch, low back flat. Long exhales through pursed lips and a pause with the air fully out. This drops the ribcage from flared to stacked — the ribs are the rotation hardware, and a flared cage is mechanically blocked from turning.",
                        chips: ["60s", "≈ 5 breaths · pause empty"]),
                ]),
                StretchPhase(id: "golf.flow.p2", label: "Side + Seated · Rotate", steps: [
                    StretchStep(
                        id: "gf3", name: "Open Book → Arm Circle",
                        detail: "Roll to your side, top knee pinned on a pillow and it does not move. Instead of a static open book, sweep the top arm in one big arc over the head and around behind you, exhaling as it passes overhead. Then roll straight over for the other side.",
                        chips: ["60s/side", "≈ 6 breaths/side"]),
                    StretchStep(
                        id: "gf4", name: "90/90 Switch + Turn",
                        detail: "Sit up into shin box. Switch sides slowly, and each time you land, turn the chest over the front shin and exhale. Front leg trains external rotation, back leg internal — both halves of your hip restriction, and the turn on top adds the thoracic piece.",
                        chips: ["90s", "≈ 10 breaths"]),
                ]),
                StretchPhase(id: "golf.flow.p3", label: "Kneeling · Integrate", steps: [
                    StretchStep(
                        id: "gf5", name: "Thread + Open",
                        detail: "On all fours. Thread one arm under the body on the exhale, then sweep it up to the ceiling on the inhale, eyes following the hand. Continuous — never park at either end. Hips stay square over the knees.",
                        chips: ["75s/side", "≈ 8 breaths/side"]),
                    StretchStep(
                        id: "gf6", name: "Couch Sink + Rotation",
                        detail: "Elbows on the couch, hips back over the heels, let the chest sink through the arms. Then walk both hands to one side and turn the ribcage toward them, breathe, and walk to the other. Lats and thoracic extension together — three lat exercises on Monday made this one non-negotiable.",
                        chips: ["90s", "≈ 10 breaths"]),
                ]),
                StretchPhase(id: "golf.flow.p4", label: "Standing · Own It", steps: [
                    StretchStep(
                        id: "gf7", name: "Kneeling → Standing Club Turns",
                        detail: "Half-kneeling, club across the shoulders, turn toward the front knee and back, exhaling into each turn. Switch knees. Then stand into golf posture and keep turning — slow, progressively bigger, building into half swings. Never end a mobility session passive.",
                        chips: ["150s", "≈ 16 breaths"]),
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
            ],
            cadence: .interval)
    }
}
