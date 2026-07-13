# RecompApp

Native iOS app for the 8-Week Recomp Protocol (Mar 30 – May 25, 2026). Pure SwiftUI + SwiftData — no external dependencies. Personal-use only, installed via Xcode sideloading to one iPhone.

## What's inside

| Tab    | Contents |
|--------|----------|
| Today  | 6-box baseline stats, Green/Yellow/Red recovery zones, 3-Day Red Rule, HRV & VO2max strategy, sauna protocol. |
| Lifts  | 7 expandable day cards (Mon–Sun). Each exercise row taps to reveal the rationale. Stretches, ab circuits, HIFT, mobility flows — all colour-coded to match the web mock. |
| Log    | Weight tracker. Day chip selector (Mon/Tue/Thu/Fri/Sat). Set-by-set weight + reps entry. Auto-loads today's log so you can resume editing. SwiftData history, expandable. Eastern Time timezone. |
| Fuel   | Training / Rest / Social day meal plans, alcohol rules, dining-out rules. |
| Sleep  | Sleep schedule, wind-down protocol, full supplement stack (Morning / Caffeine / Nighttime). |
| Plan   | Progressive overload, ab-circuit progressions (Wk 5–8), deload, taper, expected timeline. |

## Build & install to your iPhone

### Prerequisites
- macOS with **Xcode 15 or later** (this project uses synchronized folder groups, which require Xcode 15+).
- A free Apple ID (no paid developer account needed).
- A Lightning/USB-C cable to connect your iPhone.
- If Xcode prompts you, install the **iOS platform** from Xcode → Settings → Components.

### First-time setup (5 min)

1. **Open the project**
   ```
   open RecompApp.xcodeproj
   ```

2. **Add your Apple ID to Xcode**
   - Xcode → Settings → Accounts → `+` → Apple ID → sign in.

3. **Pick your signing team**
   - Click the top-level `RecompApp` project in the sidebar.
   - Select the `RecompApp` target.
   - Go to the **Signing & Capabilities** tab.
   - **Team:** pick your personal team (shows as "Your Name (Personal Team)").
   - Leave "Automatically manage signing" checked.
   - The bundle identifier is `com.kirk.recomp`. If Xcode complains it's taken, change it to something unique like `com.yourname.recomp`.

4. **Connect and trust your iPhone**
   - Plug the phone into the Mac.
   - Unlock it. Tap "Trust This Computer" if prompted.
   - In Xcode's device selector (top bar), choose your iPhone.

5. **Build + run**
   - Hit ⌘R or the Play button.
   - First build may take 1–2 minutes.
   - When it launches, iOS will block the app the first time with "Untrusted Developer."

6. **Trust the developer on your phone**
   - Settings → General → VPN & Device Management → Developer App → tap your Apple ID → Trust.
   - Go back to the home screen and launch **RecompApp**.

That's it. The app is now installed. Tap any day card in Lifts to expand it; tap any exercise row to see the rationale.

### About the 7-day certificate

Free Apple IDs sign apps with a 7-day provisioning profile. The app **stops launching after 7 days** until you rebuild from Xcode. To refresh:

1. Plug the phone in.
2. Open the project in Xcode.
3. Hit ⌘R.

That's the full refresh. Takes ~30 seconds.

Optional: delete the old build from the phone first if you want a clean install. Your workout logs live in the app's SwiftData store, which is part of its sandbox — deleting the app **will** erase them. To keep logs across reinstalls, just do a rebuild without uninstalling first.

## Project layout

```
RecompApp/
├── RecompAppApp.swift        # @main, SwiftData ModelContainer
├── ContentView.swift         # Top bar + 6-tab TabView
├── Design/
│   ├── Theme.swift           # Colour tokens from the web mock
│   └── Typography.swift      # SF Pro + SF Mono scales
├── Models/
│   ├── WorkoutLog.swift      # @Model — a saved day's session
│   └── SetEntry.swift        # @Model — one set within a log
├── Components/               # Reusable: Card, Chip, Tag, RuleItem, InfoBlock, ZoneCard, SectionLabel
├── Views/
│   ├── Today/TodayView.swift
│   ├── Lifts/                # LiftsView + DayCard + 6 row types
│   ├── Log/                  # LogView + day chips + set inputs
│   ├── Fuel/
│   ├── Sleep/
│   └── Plan/
└── Resources/                # All programme content (one file per day + Today/Fuel/Sleep/Plan)
```

All content lives in the `Resources/` folder. Views never hardcode strings.

## Tech choices

- **Swift 5.9 / SwiftUI** — min iOS 17.
- **SwiftData** — local persistence. No CloudKit, no account, no sync.
- **No 3rd-party dependencies.** Everything is Foundation + SwiftUI + SwiftData.
- **Dark mode only** — locked to match the mock.
- **Eastern Time** — `America/New_York` is hardcoded for the date shown on the Log tab and the date used for log keys.

## Editing content

Change any exercise, meal, stretch, or supplement by editing files under `Resources/`. Views re-render automatically on the next launch. The file structure is:

- `Today.swift` — stats, recovery rules, HRV strategy, sauna protocol
- `Lifts+Monday.swift` … `Lifts+Sunday.swift` — one file per day of the lifts schedule
- `LogExercises.swift` — which exercises show up on the Log tab per weekday
- `Fuel.swift` — meal plans + alcohol/dining rules
- `Sleep.swift` — schedule + supplement stack
- `Plan.swift` — overload table, ab progression, deload, taper, timeline

## Known limitations (by design)

- iPhone portrait only. No iPad layout.
- No iCloud sync. Your logs are on this one phone.
- No HealthKit, no widgets, no Watch companion, no Shortcuts, no push notifications.
- No App Store submission.
