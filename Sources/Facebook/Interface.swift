import Foundation
import UIKit

public struct FacebookClient {
  public let appDidFinishLaunching: ([UIApplication.LaunchOptionsKey: Any]?) -> Void
  public let appOpenURL: (URL, String?) -> Void

  public init(
    appDidFinishLaunching: @escaping ([UIApplication.LaunchOptionsKey: Any]?) -> Void,
    appOpenURL: @escaping (URL, String?) -> Void
  ) {
    self.appDidFinishLaunching = appDidFinishLaunching
    self.appOpenURL = appOpenURL
  }
}
