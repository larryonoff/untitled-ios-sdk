import Foundation
import UIKit

public struct FacebookClient {
  public var appDidFinishLaunching: @Sendable ([UIApplication.LaunchOptionsKey: Any]?) async -> Void
  public var appOpenURL: @Sendable (URL, [UIApplication.OpenURLOptionsKey: Any]) async -> Void
}
