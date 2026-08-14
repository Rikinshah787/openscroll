import SwiftUI

/// "Sleep mode" — blocks all platforms during a user-set window. Free, obviously.
@MainActor
final class SleepModeManager: ObservableObject {
    @AppStorage("openscroll-sleep-enabled") var isEnabled = false
    @AppStorage("openscroll-sleep-start") var startMinutes = 22 * 60  // 22:00
    @AppStorage("openscroll-sleep-end") var endMinutes = 7 * 60       // 07:00

    @Published private(set) var isBlocking = false
    private var timer: Timer?

    init() {
        evaluate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.evaluate() }
        }
    }

    func evaluate() {
        guard isEnabled else {
            isBlocking = false
            return
        }
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let minutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        if startMinutes <= endMinutes {
            isBlocking = minutes >= startMinutes && minutes < endMinutes
        } else {
            // Overnight window, e.g. 22:00 → 07:00
            isBlocking = minutes >= startMinutes || minutes < endMinutes
        }
    }
}

struct SleepModeOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.yellow)
                Text("Sleep mode")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("You set this time aside for yourself.\nThe feeds will still be there tomorrow.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}
