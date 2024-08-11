import UIKit

extension UIWindow {
  public var topMostViewController: UIViewController? {
    rootViewController?.topMostViewController
  }
}
