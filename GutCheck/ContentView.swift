import SwiftUI
import SwiftData

@main struct MyApp: App {
    // Single on-disk SwiftData container for the whole app's lifetime, so
    // logged days and the food catalog survive quitting/relaunching.
    let container: ModelContainer = {
        let schema = Schema(PersistenceSchema.models)
        let config = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
}

struct ContentView: View {
    @StateObject private var logStore: DayLogStore
    @StateObject private var foodCatalog: FoodCatalogStore

    /// - Parameter seedSampleDataIfEmpty: pass `false` for the real app so a
    ///   fresh install starts truly empty; previews leave it `true` so they
    ///   always have something to show.
    init(modelContext: ModelContext, seedSampleDataIfEmpty: Bool = false) {
        _logStore = StateObject(wrappedValue: DayLogStore(context: modelContext, seedSampleDataIfEmpty: seedSampleDataIfEmpty))
        _foodCatalog = StateObject(wrappedValue: FoodCatalogStore(context: modelContext, seedSampleDataIfEmpty: seedSampleDataIfEmpty))
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }

            LogView()
                .tabItem { Label("Log", systemImage: "calendar") }

            TrendsView()
                .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }

            FoodsView()
                .tabItem { Label("Foods", systemImage: "fork.knife") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .environmentObject(logStore)
        .environmentObject(foodCatalog)
    }
}









#Preview {
    ContentView(modelContext: PersistenceSchema.previewContext(), seedSampleDataIfEmpty: true)
}
