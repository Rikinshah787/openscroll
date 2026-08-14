import SwiftUI
import WebKit

/// Full-screen browser for one platform, with blocking rules injected.
struct PlatformBrowserView: View {
    let platform: Platform
    let onClose: () -> Void

    @EnvironmentObject var ruleStore: RuleStore
    @EnvironmentObject var timeTracker: TimeTracker
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            PlatformWebView(platform: platform, rules: ruleStore.rules(for: platform.id))
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(platform.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done", action: onClose)
                    }
                }
        }
        .onAppear { timeTracker.startSession(platformID: platform.id) }
        .onDisappear { timeTracker.endSession() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                timeTracker.startSession(platformID: platform.id)
            } else {
                timeTracker.endSession()
            }
        }
    }
}

/// WKWebView wrapper with CSS/JS rule injection and URL interception.
struct PlatformWebView: UIViewRepresentable {
    let platform: Platform
    let rules: PlatformRules?

    func makeCoordinator() -> Coordinator {
        Coordinator(rules: rules)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Shared default store → user logs in once per platform, cookies persist.
        config.websiteDataStore = .default()

        if let rules {
            let script = WKUserScript(
                source: rules.generatedScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            config.userContentController.addUserScript(script)
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.load(URLRequest(url: platform.homeURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Rules update live: re-inject when a newer rules.json arrives.
        if context.coordinator.rules !== rules {
            context.coordinator.rules = rules
            uiView.configuration.userContentController.removeAllUserScripts()
            if let rules {
                uiView.configuration.userContentController.addUserScript(
                    WKUserScript(source: rules.generatedScript,
                                 injectionTime: .atDocumentStart,
                                 forMainFrameOnly: false)
                )
            }
            uiView.reload()
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var rules: PlatformRules?

        init(rules: PlatformRules?) {
            self.rules = rules
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url,
                  let rules,
                  navigationAction.targetFrame?.isMainFrame == true else {
                decisionHandler(.allow)
                return
            }

            let path = url.path.lowercased()

            // Hard-blocked surfaces (e.g. /reels, /shorts, /explore)
            if rules.blockedPathPrefixes.contains(where: { path.hasPrefix($0.lowercased()) }) {
                decisionHandler(.cancel)
                // Bounce back to safety: if there's history, go back; else go home.
                if webView.canGoBack {
                    webView.goBack()
                } else {
                    webView.load(URLRequest(url: rules.fallbackURL))
                }
                return
            }

            // Stay inside the platform: open external links in Safari.
            if let host = url.host?.lowercased(),
               !rules.allowedHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) {
                decisionHandler(.cancel)
                UIApplication.shared.open(url)
                return
            }

            decisionHandler(.allow)
        }
    }
}
