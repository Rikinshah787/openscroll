import SwiftUI

/// Home grid of supported platforms. Tapping one opens its managed WebView.
struct PlatformGridView: View {
    @Binding var selectedPlatform: Platform?
    @EnvironmentObject var timeTracker: TimeTracker

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Take back your time.")
                        .font(.largeTitle.bold())
                    Text("Social media without the slot machine. Everything free, everything on-device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Platform.all) { platform in
                        Button { selectedPlatform = platform } label: {
                            VStack(spacing: 10) {
                                Image(systemName: platform.icon)
                                    .font(.system(size: 32))
                                Text(platform.name)
                                    .font(.headline)
                                Text(timeTracker.formattedTime(for: platform.id))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
