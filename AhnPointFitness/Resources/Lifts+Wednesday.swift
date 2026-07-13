import Foundation

extension Programme {
    static let wednesday = DayContent(
        day: .wed,
        title: "Wed · Zone 2 + Recovery",
        subtitle: "25–30 min Zone 2 + 15 min stretch",
        tag: .rest,
        sections: [
            .intro("Zone 2 cardio is now a standing session — 25–30 min, conversational pace. Only skip on a red recovery day."),
            .cardioFinisher(
                title: "",
                options: [
                    .init("wed-c1", "Incline Walk", ["25-30 min", "12-15%, 3.0-3.5 mph", "Zone 2"]),
                    .init("wed-c2", "Easy Jog", ["25-30 min", "9:00-10:00/mi", "Zone 2"]),
                    .init("wed-c3", "Assault Bike", ["20-25 min", "50-60 RPM", "Zone 2"]),
                    .init("wed-c4", "Stairmaster", ["20-25 min", "Lvl 5-7", "Zone 2"])
                ],
                note: "This is the week's aerobic base — steady Zone 2, no pushes. Intervals live on Mon/Thu."
            ),
            .saunaNote("🧖 SAUNA: 20 min infrared. Come in just for this if skipping cardio. Deepest recovery day — promotes parasympathetic activation."),
            .infoBlock(title: nil,
                       body: "Mid-week reset. Hits the tissues loaded hardest by Mon (back/chest/cardio) and Tue (legs), primes the shoulders for Thu. Shorter than Sunday but targets the same patterns."),
            .stretchBlocks(title: "⬇ Mid-Week Stretch · 15 min ⬇", blocks: [
                StretchBlock(label: "Block 1 · Shoulders + T-Spine (5 min)", stretches: [
                    .init("wed-s1", "Open Book (side-lying)", ["6 reps/side", "2s hold top"],
                          "Thoracic rotation. Undoes Monday's bench + rowing volume and preps Thursday's overhead pressing. Lie on side, knees bent, top arm sweeps across and opens toward ceiling."),
                    .init("wed-s2", "Foam Roller T-Spine Extension", ["90s"],
                          "Roller at mid-back, arms overhead. Opens the anterior chest wall and reverses the pressing-induced kyphosis from Monday."),
                    .init("wed-s3", "Shoulder CARs", ["5/direction/side"],
                          "Full shoulder circles. Signals the nervous system that full ROM is safe before Thursday's overhead work.")
                ]),
                StretchBlock(label: "Block 2 · Hips + Lower Body (6 min)", stretches: [
                    .init("wed-s4", "World's Greatest Stretch", ["4/side slow"],
                          "Lunge + rotate + reach. Hits hip flexors, thoracic rotation, hamstrings, adductors in one move. Most efficient use of 90 seconds in all of stretching."),
                    .init("wed-s5", "Couch Stretch", ["60s/side"],
                          "Deep iliopsoas + rectus femoris release. Tuesday's squats shortened these — restore length before Saturday's athletic work."),
                    .init("wed-s6", "90/90 Hip Switch + Hold", ["6 transitions + 10s holds"],
                          "Internal and external hip rotation. Squats lock you into sagittal plane — this reclaims rotational ROM.")
                ]),
                StretchBlock(label: "Block 3 · Posterior Chain + Decompression (4 min)", stretches: [
                    .init("wed-s7", "Prayer Lat Stretch (kneeling)", ["45s × 2"],
                          "Kneel in front of a couch or bed. Forearms flat, hands in prayer. Sit hips back and let chest drop. Lengthens lats and teres major — no hanging needed, works from anywhere."),
                    .init("wed-s8", "Supine Spinal Twist", ["45s/side"],
                          "Lumbar erectors, QL, obliques. Tuesday's squats braced the spine for the whole session — this rotates and decompresses."),
                    .init("wed-s9", "Child's Pose + Box Breathing", ["60s · 4-4-4-4"],
                          "Wide knees, reach far. 4 sec inhale, 4 sec hold, 4 sec exhale, 4 sec hold. Vagus nerve activation → HRV support going into the back half of the week.")
                ])
            ])
        ]
    )
}
