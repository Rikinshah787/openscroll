import SwiftUI

struct StatsView: View {
    @EnvironmentObject var timeTracker: TimeTracker

    private var totalSeconds: Int {
        timeTracker.secondsToday.values.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    HStack {
                        Text("Total time on social apps")
                        Spacer()
                        Text(format(totalSeconds))
                            .bold()
                    }
                }
                Section("By platform") {
                    ForEach(Platform.all) { platform in
                        HStack {
                            Label(platform.name, systemImage: platform.icon)
                            Spacer()
                            Text(timeTracker.formattedTime(for: platform.id))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section {
                    Text("Stats live only on this device. Nothing is uploaded, synced, or sold — there's no server to send it to.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Your time")
        }
    }

    private func format(_ s: Int) -> String {
        if s < 60 { return "\(s)s" }
        let m = s / 60
        if m < 60 { return "\(m)m" }
        return "\(m / 60)h \(m % 60)m"
    }
}
