# Contributing to OpenScroll

## The #1 way to help: fix blocking rules

Social platforms A/B test their DOM constantly, so selectors rot fast. If you see a Reel, Short, ad, or suggested post slip through:

1. Open [`OpenScroll/Resources/rules.json`](OpenScroll/Resources/rules.json)
2. Find the platform, add/fix the CSS selector or blocked path
3. Bump `version` by 1
4. Open a PR with a screenshot of the leak if possible

Apps fetch the latest `rules.json` from `main` on launch, so merged fixes ship to everyone **without an App Store release**.

## Selector rules of thumb

- Prefer attribute selectors (`a[href^="/reels"]`) over class names (`.x9f619`) — classes are obfuscated and change weekly; URL paths are stable.
- Use `:has()` sparingly (iOS 17+ supports it) — it's powerful but costs performance in MutationObserver loops.
- Never hide `main`, `[role="main"]`, or anything that would take DMs/profiles down with it. Surgical, not nuclear.

## Code

- Zero dependencies is a hard rule. Everything must be stdlib + Apple frameworks.
- No analytics, no telemetry, no network calls except fetching `rules.json`. PRs adding tracking will be rejected on principle.
- Keep it simple. If a feature needs a backend, it doesn't belong here.
