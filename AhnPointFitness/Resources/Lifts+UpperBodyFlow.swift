import Foundation

extension Programme {
    /// Shared post-lift flow for the two upper-body days. Monday and Friday
    /// had near-identical stretch lists authored twice; one flow, run from
    /// standing down to the floor so you never get back up, replaces both.
    /// Pressing and rowing days are what stiffen the upper back — this is
    /// where the golf rotation work is either protected or undone.
    static let upperBodyFlow = [
        StretchBlock(label: "Upper Body Flow · standing → floor", stretches: [
            .init("ub-1", "Doorway Pec · 90° then 135°", ["60s/side", "30s each height"],
                  "Forearm on the frame at shoulder height, step through and rotate away; then slide the hand high and repeat. Sternal fibres then clavicular — bench and incline both shorten these, and short pecs pull you into the flexion that kills rotation."),
            .init("ub-2", "Cross-Body Posterior Delt", ["40s/side"],
                  "Arm across the chest, pull above the elbow, shoulder stays down. Rear delt and infraspinatus, tight from rows and face pulls."),
            .init("ub-3", "Couch Sink + Rotation", ["90s", "≈ 10 breaths"],
                  "Kneel, elbows on the couch, hips back, chest sinks through. Walk the hands to each side and turn the ribcage toward them. Lats and thoracic extension in one position."),
            .init("ub-4", "Thread + Open", ["75s/side", "≈ 8 breaths/side"],
                  "All fours. Thread the arm under on the exhale, sweep it to the ceiling on the inhale, eyes on the hand. Continuous. This is the daily thoracic rotation dose — it runs on lift days too."),
            .init("ub-5", "Child's Pose · Reach Each Side", ["45s/side", "≈ 5 breaths/side"],
                  "Hips to heels, knees wide, walk both hands to one side and breathe into the opposite ribs. Lats, teres, thoracolumbar fascia, one side at a time."),
            .init("ub-6", "Supine Floor Angel", ["60s", "10 slow reps"],
                  "On your back, arms slide floor-level to overhead and back. Pec minor and anterior delt — the floor tells the truth: if the low back lifts, pec minor is the limiter."),
            .init("ub-7", "Foam Roller Thoracic Extension", ["90s", "3 levels, 5 reps each"],
                  "Finish where the golf flow starts. Roller across the mid-back, hips down, extend over it and exhale at the bottom. Undoes the kyphosis that pressing reinforces before you leave the gym.")
        ])
    ]
}
