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
  public var continueUserActivity: @MainActor @Sendable (
    _ _: NSUserActivity
  ) -> Bool = { _ in false }

  public var didFinishLaunching: @MainActor @Sendable (
    _ options: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool = { _ in false }

  @DependencyEndpoint(method: "open")
  public var openURL: @MainActor @Sendable (
    _ _: URL,
    _ options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool = { _, _ in false }

  public var anonymousID: @Sendable () -> String = { "" }

  public var userID: @Sendable () -> String?
}
