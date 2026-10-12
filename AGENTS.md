# AGENTS.md

Guidance for coding agents (Claude Code, Codex CLI) in this repository.

Shared Swift/SwiftUI/TCA house rules (via ai-toolkit):
@~/.claude/rules/onelight-apple.md

## Project Overview

`Untitled` — the shared iOS/macOS SDK consumed by the apps (Words,
Recipes, PhotoID, Drafts, …) as a local or remote SPM package. Modules are
exported under a `Duck*` prefix (`DuckCore`, `DuckPurchasesClient`, …); a few
keep their own name (`SFSymbol`, `Instagram`).

## Working Process

- **House rules before neighbours** — don't copy a pattern from this repo
  without confirming it's current; much of it predates the house rules.
- **Search before writing**: the stdlib, the Point-Free libraries and this
  package's own modules likely have it already.
- **Lint before finishing Swift changes**:
  `python3 build-system/swift-style.py lint <changed Swift files>`, tests and
  `Package.swift` included. The repo lints clean and has no baseline — fix what
  your change introduces. Layout: `format-check <files…>` to see, `format
  <files…>` to write, explicit files only. Details: `docs/linting.md`.
- **Verify before claiming done** — build or test, and quote the output.

## Debugging

Root cause before fixes (`superpowers:systematic-debugging`). Follow the user's
hint first; don't re-pitch a redirected theory. Read our code before dependency
internals.

## Key Rules

- **Edit `Package.swift` through its helpers, not inline literals.** Target and
  product names live in `extension String` (`.core`, `.Client.purchases`);
  targets are built by the `extension Target` factories. Add a module by adding
  its name constant, its `Target` factory and its `.library(...)` product.
- **Every target gets `swiftSettings: .upcomingFeatures`** (StrictConcurrency,
  ExistentialAny, ImmutableWeakCaptures, InferIsolatedConformances,
  MemberImportVisibility). A new target without it silently opts out of the
  package's safety baseline.
- **The `AppMetrica` trait is off by default** and must stay that way — it gates
  the dependency out of *resolution* so the graph resolves on macOS. See README
  for the full rationale (SR-15836). iOS consumers opt in.
- **NEVER edit `*.generated.swift`** — run `bundle exec fastlane ios swiftgen`
  (regenerates PaywallReducer, PurchasesCore, NotificationsAccessFeature,
  RateUsFeature).
- **NEVER commit or tag a release** without explicit user instruction. Apps
  consume this package by version; a tag is a publish. Commits go straight to
  `main`; don't create branches unless asked.
- **This is a library, not an app.** A change here lands in every app — check
  consuming call sites before changing a public signature.

## Commands

| Task | Command |
|---|---|
| Build | `swift build` (resolves on macOS with the default traits) |
| Build with AppMetrica | `swift build --traits AppMetrica` (iOS destination) |
| Run tests (iOS) | `xcodebuild test -scheme Untitled-Package -destination 'platform=iOS Simulator,name=<iPhone>' [-only-testing:<Target>]` |
| Lint changed Swift files | `python3 build-system/swift-style.py lint <files…>` |
| Check / apply layout | `python3 build-system/swift-style.py format-check\|format <files…>` |
| Regenerate assets/strings | `bundle exec fastlane ios swiftgen` |

## Testing

Swift Testing only (`@Suite`, `@Test`, `#expect`). `Untitled-Package` is the one
scheme and runs every test target; a new `.testTarget` needs nothing else. Code
under `#if canImport(UIKit)` — `VideoPlayer` and its tests — compiles out of
`swift build`/`swift test` on macOS, so verify it with `xcodebuild` on a
simulator. A test double behaves like the real dependency on the path under
test; otherwise green hides the bug.

## Platform & Stack

- **Swift tools 6.3**, Swift 6 language mode. Library floor: iOS 18 / macOS 15.
- **Stack**: Point-Free (TCA, Dependencies, Sharing, Navigation, Tagged,
  CustomDump, ConcurrencyExtras, IssueReporting) + swift-collections. Vendor
  SDKs: Adapty, AppMetrica, Facebook, Firebase, DeviceKit, KeychainAccess.

## Layout

One target per `Sources/<Module>` directory. Dependency clients follow the house
layout — `Interface.swift`, `Live.swift`, `TestKey.swift`, plus `Exports.swift`
for re-exports, `Analytics.swift`, and `Internal/` for implementation helpers.

## Code Style

- Use Apple `Synchronization.Mutex` for synchronous shared mutable state. Do not add a Mutex backport or export a same-named wrapper from DuckFoundation.

Formatting: `.editorconfig` — 2-space indent, trim trailing whitespace, final
newline — applied by SwiftFormat through `build-system/swift-style.py`.
Everything else: the house-rules import above.
