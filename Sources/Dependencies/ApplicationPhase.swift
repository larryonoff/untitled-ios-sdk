import Foundation

/// The running phase of the app.
///
/// Named and ordered after SwiftUI's `ScenePhase`, which models the same three
/// states — the vocabulary is shared so code moving between UIKit and SwiftUI
/// reads the same. `Comparable` lets a caller ask `phase >= .inactive`
/// ("on screen at all") instead of listing cases.
public enum ApplicationPhase: Comparable, Hashable, Sendable {
  /// Running in the background.
  case background
  /// On screen but not receiving events — a system alert, the app switcher, a
  /// call banner.
  case inactive
  /// On screen and receiving events.
  case active
}
