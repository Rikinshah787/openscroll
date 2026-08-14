import Foundation

/// Tracks foreground time per platform. 100% on-device (UserDefaults).
@MainActor
final class TimeTracker: ObservableObject {
    @Published private(set) var secondsToday: [String: Int] = [:]

    private var activePlatformID: String?
    private var sessionStart: Date?
    private var ticker: Timer?

    private var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "openscroll-time-" + f.string(from: Date())
    }

    init() {
        secondsToday = UserDefaults.standard.dictionary(forKey: todayKey) as? [String: Int] ?? [:]
    }

    func startSession(platformID: String) {
        guard activePlatformID == nil else { return }
        activePlatformID = platformID
        sessionStart = Date()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func endSession() {
        tick()
        ticker?.invalidate()
        ticker = nil
        activePlatformID = nil
        sessionStart = nil
        persist()
    }

    private func tick() {
        guard let id = activePlatformID, let start = sessionStart else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        guard elapsed > 0 else { return }
        secondsToday[id, default: 0] += elapsed
        sessionStart = Date()
    }

    private func persist() {
        UserDefaults.standard.set(secondsToday, forKey: todayKey)
    }

    func formattedTime(for platformID: String) -> String {
        let s = secondsToday[platformID, default: 0]
        if s < 60 { return "\(s)s today" }
        let m = s / 60
        if m < 60 { return "\(m)m today" }
        return "\(m / 60)h \(m % 60)m today"
    }
}
