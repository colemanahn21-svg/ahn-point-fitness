import SwiftUI
import SwiftData

@main
struct AhnPointFitnessApp: App {
    @StateObject private var whoopAuth = WhoopAuth()
    @Environment(\.scenePhase) private var scenePhase

    let container: ModelContainer = {
        let schema = Schema([WorkoutLog.self, SetEntry.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
                .environmentObject(whoopAuth)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await whoopAuth.refreshIfNeeded() }
                    }
                }
                .task {
                    // Launch-argument hook (screenshots / UI tests):
                    // `-seedDemo YES` populates the app with demo data.
                    if UserDefaults.standard.bool(forKey: "seedDemo") {
                        let ctx = container.mainContext
                        let existing = (try? ctx.fetch(FetchDescriptor<WorkoutLog>())) ?? []
                        DemoSeeder.seed(into: ctx, existing: existing)
                    }
                }
        }
        .modelContainer(container)
    }
}
