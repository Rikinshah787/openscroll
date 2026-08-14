import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sleepMode: SleepModeManager
    @State private var selectedPlatform: Platform?

    var body: some View {
        TabView {
            PlatformGridView(selectedPlatform: $selectedPlatform)
                .tabItem { Label("Browse", systemImage: "square.grid.2x2") }

            StatsView()
                .tabItem { Label("Time", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .fullScreenCover(item: $selectedPlatform) { platform in
            PlatformBrowserView(platform: platform) {
                selectedPlatform = nil
            }
        }
        .overlay {
            if sleepMode.isBlocking {
                SleepModeOverlay()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(RuleStore())
        .environmentObject(TimeTracker())
        .environmentObject(SleepModeManager())
}
