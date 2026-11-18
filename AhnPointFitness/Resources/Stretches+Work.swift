import Foundation

/// Counter-programming for a desk day.
///
/// Sitting is not an injury and no single posture causes pain. The problem is
/// eight hours in one: hips held at 90° flexion, a rounded thoracic spine, arms
/// forward on a keyboard, wrists extended. For a golfer whose limiter is
/// thoracic turn, that is the exact shape that steals rotation, so both flows
/// open into extension before anything turns, as the golf flow does.
///
/// Desk Reset runs once a workday, after lunch, and fits a cramped desk:
/// standing beside the chair, then back in it. No floor, no lunging, nothing
/// beyond the chair and the desk. The evening at home is whatever the
/// schedule says (see StretchSchedule); the hips get their long work in
/// Lower Body Flow.
extension StretchLibrary {
    enum Work {

        static let deskReset = StretchRoutine(
            id: "work.desk",
            name: "Desk Reset",
            subtitle: "Standing to seated · fits beside the chair",
            focus: .desk,
            phases: [
                StretchPhase(id: "work.desk.p1", label: "Standing · Beside the Chair", steps: [
                    StretchStep(
                        id: "wd1", name: "Short-Stance Hip Flexor + Reach",
                        detail: "Stand up, one hand on the desk, back foot only a shoe-length behind. The stretch comes from tucking the pelvis and squeezing the back-leg glute, not from lunging, so it needs no more room than standing does. Then reach the back-side arm overhead and lean away. Hip flexors sit shortened for every hour you sit, and short hip flexors tip the pelvis forward at address.",
                        chips: ["40s/side", "≈ 4 breaths/side"]),
                    StretchStep(
                        id: "wd2", name: "Desk Wrist Flexor → Extensor",
                        detail: "Palms flat on the desk with the fingers toward you, elbows straight, lean back gently. Halfway through, flip to the backs of the hands. Typing keeps the wrists extended all day, and grip work and golf load the same tendons at the elbow. Stretch, never tingling. Tingling means a nerve, so back off.",
                        chips: ["45s", "≈ 5 breaths · flip halfway"]),
                ]),
                StretchPhase(id: "work.desk.p2", label: "Seated · Open, Then Turn", steps: [
                    StretchStep(
                        id: "wd2b", name: "Seat-Edge Hamstring Hinge",
                        detail: "Sit on the front edge of the seat, one leg straight out with the heel down and toes up. Hinge forward from the hips with a flat back until the back of the thigh pulls. No extra room needed, and it gives the hamstrings a dose every workday instead of only after RDLs.",
                        chips: ["30s/side", "≈ 3 breaths/side"]),
                    StretchStep(
                        id: "wd3", name: "Chair-Back Extension",
                        detail: "Slide all the way to the back of the seat so the top edge meets the mid-back. Hands behind the head, elbows wide, and on each exhale arch the upper back over the edge. This is the reverse of the keyboard hunch, and it comes before the turn because the thoracic spine rotates far less from a flexed position.",
                        chips: ["45s", "≈ 5 breaths"]),
                    StretchStep(
                        id: "wd4", name: "Seated Thoracic Turn",
                        detail: "Feet flat, knees pressed together. That pins the pelvis, so the turn has to come from the ribcage and not the low back. Sit tall on the inhale and turn on the exhale, far hand to the outside of the knee, near hand to the chair back. Same rotation your backswing needs.",
                        chips: ["30s/side", "≈ 3 breaths/side"]),
                    StretchStep(
                        id: "wd5", name: "Seated Desk Sink",
                        detail: "Forearms on the desk edge, roll the chair back a few inches, and hinge from the hips so the chest sinks between the arms. Lats and thoracic extension, the seated version of the prayer stretch, inside the space the chair already uses.",
                        chips: ["45s", "≈ 5 breaths"]),
                    StretchStep(
                        id: "wd6", name: "Upper Trap + Levator Scap",
                        detail: "Hand under the seat to anchor the shoulder down. Ear toward the other shoulder for upper trap, then nose 45° toward the armpit for levator scapulae. These are the two that hold the head up while it drifts toward the screen. You finish in the chair, ready to work.",
                        chips: ["30s/side", "≈ 3 breaths/side"]),
                ]),
            ])
    }
}
