import Foundation

extension Programme {
    /// Shared flow for the two lower-body days: Tuesday legs and Saturday
    /// conditioning. Standing to the floor, one direction, ending on the
    /// breath. Squats and RDLs already move the legs through long ranges
    /// under load; this covers what they leave short (hip flexors, adductors,
    /// deep hip rotators), the squat-depth limiter (soleus), and the hamstring
    /// length a hinge at address depends on.
    static let lowerBodyFlow = [
        StretchBlock(label: "Lower Body Flow · standing → floor", stretches: [
            .init("lb-1", "Elevated Hamstring Stretch", ["45s/side", "≈ 5 breaths/side"],
                  "Heel on the couch arm, leg straight, hinge from the hip with a flat back and pull the toes toward you. RDLs load the hamstrings long; this returns them to resting length, and your address posture is a hamstring hinge."),
            .init("lb-2", "Wall Calf · Bent Knee", ["30s/side", "≈ 3 breaths/side"],
                  "Ball of the foot on the wall, knee bent and driven over the toes. Bent knee targets soleus, the calf muscle that limits how deep you can squat with the heels down."),
            .init("lb-3", "Couch Stretch", ["60s/side", "≈ 6 breaths/side"],
                  "Rear shin up the couch, front foot flat, tuck the pelvis and squeeze the back glute. Rectus femoris and psoas: shortened by squats and by every hour in a chair. The strongest hip flexor stretch there is."),
            .init("lb-4", "Adductor Rock-Back", ["45s/side", "≈ 5 breaths/side"],
                  "All fours, one leg straight out to the side. Rock back toward the heel on the exhale. Adductors stabilise the trail leg in the backswing and take load in every wide-stance lift."),
            .init("lb-5", "Pigeon Pose", ["60s/side", "≈ 6 breaths/side"],
                  "Shin across, back leg long, square the hips and fold when it settles. Glutes and deep rotators: the lead hip has to turn through impact."),
            .init("lb-6", "Supine Spinal Twist", ["45s/side", "≈ 5 breaths/side"],
                  "Knees together, drop them to one side, opposite shoulder down. Low back and obliques after a session of bracing."),
            .init("lb-7", "Legs Up the Wall", ["60s", "≈ 6 breaths · long exhales"],
                  "Hips close to the wall, legs resting up it, out-breath longer than the in-breath. The switch from training to evening.")
        ])
    ]
}
