import UIKit

extension UIApplication {
  public var activeScene: UIWindowScene? {
    for scene in connectedScenes {
      guard
        scene.activationState == .foregroundActive,
        let scene = scene as? UIWindowScene
      else {
        continue
      }

      return scene
    }

    return nil
  }

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
    topMostWindow?.topMostViewController
  }
}

private extension Optional where Wrapped == UIWindow {
  var windowLevel: UIWindow.Level {
    self?.windowLevel ?? UIWindow.Level(-1000)
  }
}
