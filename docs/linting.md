# Swift lint and formatting

SwiftLint checks correctness and conventions; SwiftFormat handles a small set of layout rules. Neither runs during a build.

## Commands

From the repository root:

```sh
python3 build-system/swift-style.py lint
python3 build-system/swift-style.py lint Sources/VideoPlayer/VideoPlayerView.swift
python3 build-system/swift-style.py format-check Sources/VideoPlayer/VideoPlayerView.swift
python3 build-system/swift-style.py format Sources/VideoPlayer/VideoPlayerView.swift
```

`lint` and `format-check` without files cover `Sources`, `Tests` and `Package.swift`; generated files and build directories are excluded. Directories are rejected — pass files. `format` requires explicit files: it never writes across the repository. Install the tools with `brew install swiftlint swiftformat`.

## Configuration

- `.editorconfig` is the source of whitespace settings; the script passes them to SwiftFormat.
- `.swiftformat` enables only indentation, line endings, final newline, trailing whitespace, trailing commas and argument wrapping. It leaves `self`, imports, access control and control flow alone.
- `.swiftlint.yml` lists its rules with `only_rules`, so a tool upgrade adds no policy. Deployment targets are iOS 17.0 and macOS 15.0, matching `Package.swift`.

## No baseline

The repository lints clean, so there is no `.swiftlint-baseline.json`. Keep it that way: fix a violation rather than adding a baseline, and scope a `// swiftlint:disable` to the lines that need it (vendored license headers, for instance), with `enable` after them.
