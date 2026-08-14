import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var ruleStore: RuleStore
    @EnvironmentObject var sleepMode: SleepModeManager

    var body: some View {
        NavigationStack {
            List {
                Section("Sleep mode") {
                    Toggle("Enable sleep mode", isOn: $sleepMode.isEnabled)
                    if sleepMode.isEnabled {
                        MinutePicker(label: "Starts", minutes: $sleepMode.startMinutes)
                        MinutePicker(label: "Ends", minutes: $sleepMode.endMinutes)
                    }
                }

                Section("Blocking rules") {
                    HStack {
                        Text("Rules version")
                        Spacer()
                        Text(ruleStore.file.map { "v\($0.version)" } ?? "—")
                            .foregroundStyle(.secondary)
                    }
                    Button("Update rules now") {
                        Task { await ruleStore.refresh() }
                    }
                    Text("Rules update automatically from the open-source repo. Selector fixes ship to everyone without an App Store update.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    LabeledContent("Price", value: "Free. Forever.")
                    LabeledContent("Data collection", value: "None. No servers.")
                    Link("Source code", destination: URL(string: "https://github.com/Rikinshah787/openscroll")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

/// Simple hour:minute wheel picker backed by "minutes since midnight".
private struct MinutePicker: View {
    let label: String
    @Binding var minutes: Int

    private var date: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: minutes / 60, minute: minutes % 60)) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                minutes = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        )
    }

    var body: some View {
        DatePicker(label, selection: date, displayedComponents: .hourAndMinute)
    }
}
