#if canImport(UIKit)

import Dependencies
import DependenciesMacros
import Foundation
import UIKit

extension DependencyValues {
  public var facebook: FacebookClient {
    get { self[FacebookClient.self] }
    set { self[FacebookClient.self] = newValue }
  }
}

@DependencyClient
public struct FacebookClient: Sendable {
  public var continueUserActivity: @Sendable (
    _ _: NSUserActivity
  ) -> Bool = { _ in false }

  public var didFinishLaunching: @Sendable (
    _ options: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool = { _ in false }

  /// Hands a URL the app was opened with to the SDK, which claims the ones
  /// belonging to its own login and dialog flows.
  ///
  /// Spelled in `sourceApplication`/`annotation` rather than in any one UIKit
  /// callback's shape because that is the SDK's own canonical entry point —
  /// its `options:` dictionary overload just unpacks these two keys, and its
  /// `continue userActivity` overload passes neither. So each caller supplies
  /// them from whatever it has: a `UIOpenURLContext.options` under the scene
  /// lifecycle (`UIApplicationDelegate.application(_:open:options:)` being
  /// deprecated in iOS 26), an options dictionary under the app lifecycle.
  @DependencyEndpoint(method: "open")
  public var openURL: @Sendable (
    _ _: URL,
    _ sourceApplication: String?,
    _ annotation: (any Sendable)?
  ) -> Bool = { _, _, _ in false }

  public var anonymousID: @Sendable () -> String = { "" }

  public var userID: @Sendable () -> String?
}

#endif
