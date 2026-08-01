# sugar

## Package traits

### `AppMetrica`

**Off by default. iOS apps that report analytics must enable it.**

```swift
.package(
  url: "https://github.com/…/untitled-ios-sdk",
  from: "…",
  traits: ["AppMetrica"]
)
```

AppMetrica declares no macOS platform, so SPM defaults its libraries to macOS
10.13 while its own KSCrash dependency requires 10.14. That contradiction fails
the entire package graph on macOS — every target, not just the AppMetrica ones —
which breaks `swift build` and CI outright.

`.when(platforms: [.iOS])` cannot fix this: a condition gates *linking*, not
*resolution*, and the graph is validated before conditions apply ([SR-15836][]).
A trait is the only mechanism that keeps the dependency out of resolution
entirely, and SPM offers no way to key a trait off the target platform — hence
the manual opt-in.

With the trait disabled, `DuckAppMetricaClient` has no live implementation and
`@Dependency(\.appMetrica)` reports an issue and falls back to a no-op.

[SR-15836]: https://forums.swift.org/t/adding-platform-specific-dependency-to-multi-platform-swift-package/49645
