import SwiftUI
import Playgrounds

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView{
            TodayView()
                .tabItem{
                    Label("Today", systemImage: "sun.max")
                }
            LogView()
                .tabItem{
                    Label("Log", systemImage: "calendar")
                }
            TrendsView()
                .tabItem{
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
            FoodsView()
                .tabItem{
                    Label("Foods", systemImage: "fork.knife")
                }
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "gearshape")
                }
                        
        }
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
