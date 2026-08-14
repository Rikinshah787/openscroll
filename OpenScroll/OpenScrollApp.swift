import SwiftUI

@main
struct OpenScrollApp: App {
    @StateObject private var ruleStore = RuleStore()
    @StateObject private var timeTracker = TimeTracker()
    @StateObject private var sleepMode = SleepModeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ruleStore)
                .environmentObject(timeTracker)
                .environmentObject(sleepMode)
                .task { await ruleStore.load() }
        }
    }
}
