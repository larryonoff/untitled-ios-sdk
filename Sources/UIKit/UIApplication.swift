import UIKit

extension UIApplication {
  public var topMostWindow: UIWindow? {
    var topWindow: UIWindow?

    for case let scene as UIWindowScene in connectedScenes
    where scene.activationState == .foregroundActive {
      for window in scene.windows where !window.isHidden {
        if window.isKeyWindow { return window }

        if window.windowLevel >= topWindow.windowLevel {
          topWindow = window
        }
      }
    }

    return topWindow
  }

  public var topMostViewController: UIViewController? {
    guard let window = topMostWindow else {
      return nil
    }

    var topViewController = window.rootViewController

    while let presented = topViewController?.presentedViewController {
      topViewController = presented
    }

    return topViewController
  }
}

private extension Optional where Wrapped == UIWindow {
  var windowLevel: UIWindow.Level {
    self?.windowLevel ?? UIWindow.Level(-1000)
  }
}
