import Foundation

extension Programme {
    static let wednesday = DayContent(
        day: .wed,
        title: "Wed · Zone 2 + Recovery",
        subtitle: "25–30 min Zone 2 + 14 min golf flow",
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
                       body: "Tonight's stretch is the Golf Rotation Flow: the mid-week thoracic dose between Monday's pressing and Thursday's overhead work."),
            .stretchLink
        ]
    )
}
