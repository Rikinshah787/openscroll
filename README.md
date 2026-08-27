# OpenScroll

**The free, open-source alternative to paid "doomscroll blocker" apps.**

OpenScroll surgically removes the addictive parts of social media — Reels, Shorts, Explore pages, suggested posts, ads — while keeping the parts you actually need: DMs, profiles, your feed, and posting.

No subscription. No account. No servers. Everything runs and stays on your device.

## Why this exists

Apps like SocialLite charge **$48–84/year** for what is fundamentally CSS injection into a WebView. We believe attention protection should be free, auditable, and community-maintained.

| Feature | SocialLite Pro ($6.99/mo) | OpenScroll |
|---|---|---|
| Block short-form feeds | ✅ (free tier) | ✅ Free |
| Block ads | 💰 Pro | ✅ Free |
| Hide suggested posts | 💰 Pro | ✅ Free |
| Sleep mode | 💰 Pro | ✅ Free |
| Home screen widgets | 💰 Pro | ✅ Free |
| Multiple accounts | 💰 Pro | ✅ Free |
| Auditable privacy | ❌ Closed source | ✅ This repo |

## How it works

```
OpenScroll (SwiftUI, zero dependencies)
├── WKWebView per platform  — shared cookie store, login once
├── RuleEngine              — injects JS/CSS from rules.json at document start
├── URLInterceptor          — blocks /reels, /shorts, /explore navigation
├── SleepMode               — schedule-based full-screen block
└── TimeTracker             — on-device usage stats, never leaves the phone
```

The blocking rules live in [`OpenScroll/Resources/rules.json`](OpenScroll/Resources/rules.json) and update over-the-air from this repo — no app release needed when Instagram changes its DOM.

## Supported platforms

Instagram · YouTube · Reddit · TikTok · Facebook · X

## Build

Requires macOS + Xcode 15+ and [XcodeGen](https://github.com/yonsm/XcodeGen):

```bash
brew install xcodegen
xcodegen
open OpenScroll.xcodeproj
```

No third-party Swift packages. No build scripts. No signing tricks.

## Contributing

The most valuable contributions are **selector fixes** — social sites change their DOM constantly. If a Reel slips through, open `rules.json`, fix the selector, and PR it. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — do whatever you want with it. That's the point.
"# Appleapp-afterscoll" 
