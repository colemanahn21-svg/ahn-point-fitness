import Foundation

extension Programme {
    static let sunday = DayContent(
        day: .sun,
        title: "Sun · Rest + Golf Rotation Flow",
        subtitle: "14 min · the only thing on the list",
        tag: .rest,
        sections: [
            .infoBlock(title: "Why This Matters",
                       body: "No lifting. One 14-minute flow, the same one as Wednesday and Saturday: thoracic turn is your limiter, and a day with nothing else on it is the easiest day to get on the floor. The old 40-minute session is gone because it never got done. Still priorities: Sleep in (9:00–9:30a wake). Rest-day nutrition (~1,850 kcal). Hydrate 100+ oz. Full supplement stack."),
            .stretchLink,
            .infoBlock(title: "Optional Add-Ons",
                       body: "Walk: 20 min outdoors for sunlight and circadian rhythm support. Speed calibration (optional): If you go to the range, hit 20 max-effort drives with a launch monitor. No swing thoughts except \"swing as hard as you possibly can without falling over.\" Teaches your nervous system that max speed is allowed.")
        ]
    )
}
