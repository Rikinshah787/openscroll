import Foundation

/// Top-level rules file. Bundled in the app and updated over-the-air
/// from the rules repo so selector fixes ship without an App Store release.
struct RuleFile: Codable {
    let version: Int
    let platforms: [String: PlatformRules]
}

struct PlatformRules: Codable, Equatable {
    /// CSS selectors for elements to hide (reels shelves, suggested posts, ads).
    let hideSelectors: [String]
    /// URL path prefixes that must never load (e.g. "/reels", "/shorts").
    let blockedPathPrefixes: [String]
    /// Hosts the WebView is allowed to navigate to; everything else opens in Safari.
    let allowedHosts: [String]
    /// Where to send the user when a blocked page is the first navigation.
    let fallbackURLString: String

    var fallbackURL: URL { URL(string: fallbackURLString)! }

    /// JS injected at document start. Strategy:
    /// 1. Inject a <style> with `display:none` for all hide selectors (instant, zero flicker).
    /// 2. MutationObserver re-hides anything the SPA renders later.
    /// 3. history.pushState hook catches in-app SPA navigation to blocked paths.
    var generatedScript: String {
        let selectorsJSON = (try? String(data: JSONEncoder().encode(hideSelectors), encoding: .utf8)) ?? "[]"
        let blockedJSON = (try? String(data: JSONEncoder().encode(blockedPathPrefixes), encoding: .utf8)) ?? "[]"
        let fallback = fallbackURLString

        return """
        (function() {
            'use strict';
            const SELECTORS = \(selectorsJSON);
            const BLOCKED_PATHS = \(blockedJSON);
            const FALLBACK = "\(fallback)";

            function isBlocked() {
                const p = location.pathname.toLowerCase();
                return BLOCKED_PATHS.some(bp => p.startsWith(bp.toLowerCase()));
            }

            // 3. SPA navigation guard — run before anything renders.
            if (isBlocked()) {
                location.replace(FALLBACK);
                return;
            }
            const origPush = history.pushState;
            history.pushState = function() {
                origPush.apply(this, arguments);
                if (isBlocked()) history.back();
            };
            window.addEventListener('popstate', () => {
                if (isBlocked()) history.back();
            });

            // 1. Static CSS — hides matching elements before first paint.
            const css = SELECTORS.map(s => s + ' { display: none !important; }').join('\\n');
            const style = document.createElement('style');
            style.id = 'openscroll-blocker';
            style.textContent = css;
            (document.head || document.documentElement).appendChild(style);

            // 2. MutationObserver — belt and suspenders for late-rendered nodes.
            function hide(root) {
                for (const sel of SELECTORS) {
                    try {
                        root.querySelectorAll(sel).forEach(el => {
                            el.style.setProperty('display', 'none', 'important');
                        });
                    } catch (e) { /* invalid selector after site update — skip */ }
                }
            }
            const observer = new MutationObserver(mutations => {
                for (const m of mutations) {
                    for (const node of m.addedNodes) {
                        if (node.nodeType === Node.ELEMENT_NODE) hide(node.parentElement || node);
                    }
                }
            });
            function startObserving() {
                hide(document.documentElement);
                observer.observe(document.documentElement, { childList: true, subtree: true });
            }
            if (document.documentElement) startObserving();
            else document.addEventListener('DOMContentLoaded', startObserving);
        })();
        """
    }
}

/// Loads bundled rules, then refreshes from the remote rules repo.
/// Newer versions win; everything is cached on-device. No tracking, ever.
@MainActor
final class RuleStore: ObservableObject {
    @Published private(set) var file: RuleFile?

    /// Point this at the repo's raw rules.json once the repo is public.
    private let remoteURL = URL(string: "https://raw.githubusercontent.com/Rikinshah787/openscroll/main/OpenScroll/Resources/rules.json")!
    private let cacheURL: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("openscroll-rules.json")
    }()

    func load() async {
        // 1. Bundled rules — always available, even offline on first launch.
        if let bundled = Self.loadBundled() {
            file = bundled
        }
        // 2. Cached remote rules — newer than bundled wins.
        if let cached = loadCached(), cached.version > (file?.version ?? 0) {
            file = cached
        }
        // 3. Fetch fresh rules in the background.
        await refresh()
    }

    func refresh() async {
        do {
            var request = URLRequest(url: remoteURL)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, _) = try await URLSession.shared.data(for: request)
            let remote = try JSONDecoder().decode(RuleFile.self, from: data)
            if remote.version > (file?.version ?? 0) {
                file = remote
                try? data.write(to: cacheURL, options: .atomic)
            }
        } catch {
            // Offline or repo unavailable — bundled/cached rules still work.
        }
    }

    func rules(for platformID: String) -> PlatformRules? {
        file?.platforms[platformID]
    }

    private static func loadBundled() -> RuleFile? {
        guard let url = Bundle.main.url(forResource: "rules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(RuleFile.self, from: data)
    }

    private func loadCached() -> RuleFile? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(RuleFile.self, from: data)
    }
}
