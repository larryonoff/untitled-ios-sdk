# AGENTS.md

Guidance for coding agents in this repository.

Onelight Swift/SwiftUI/TCA house rules (shared via ai-toolkit):
@~/.claude/rules/onelight-apple.md

## Project Overview

`Untitled` — the shared Onelight iOS/macOS SDK consumed by the apps (Words,
Recipes, PhotoID, Drafts, …) as a local or remote SPM package. Modules are
exported under a `Duck*` prefix (`DuckCore`, `DuckPurchasesClient`, …); a few
keep their own name (`SFSymbol`, `Instagram`).

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
  consume this package by version; a tag is a publish.
- **This is a library, not an app.** A change here lands in every app — check
  consuming call sites before changing a public signature.

## Commands

| Task | Command |
|---|---|
| Build | `swift build` (resolves on macOS with the default traits) |
| Build with AppMetrica | `swift build --traits AppMetrica` (iOS destination) |
| Regenerate assets/strings | `bundle exec fastlane ios swiftgen` |

## Platform & Stack

- **Swift tools 6.3**, Swift 6 language mode. Library floor: iOS 17 / macOS 15.
- **Stack**: Point-Free (TCA, Dependencies, Sharing, Navigation, Tagged,
  CustomDump, ConcurrencyExtras, IssueReporting) + swift-collections. Vendor
  SDKs: Adapty, AppMetrica, Facebook, Firebase, DeviceKit, KeychainAccess.

## Layout

One target per `Sources/<Module>` directory. Dependency clients follow the house
layout — `Interface.swift`, `Live.swift`, `TestKey.swift`, plus `Exports.swift`
for re-exports, `Analytics.swift`, and `Internal/` for implementation helpers.

## Code Style

Formatting: `.editorconfig` — 2-space indent, trim trailing whitespace, final
newline. Everything else: the house-rules import above.
