import Dependencies
import Foundation
import UIKit

extension DependencyValues {
  public var facebook: FacebookClient {
    get { self[FacebookClient.self] }
    set { self[FacebookClient.self] = newValue }
  }
}

public struct FacebookClient {
  public var appDidFinishLaunching: ([UIApplication.LaunchOptionsKey: Any]?) -> Void
  public var appOpenURL: (URL, [UIApplication.OpenURLOptionsKey: Any]) -> Void
  public var anonymousID: @Sendable () -> String
  public var userID: @Sendable () -> String?
}
