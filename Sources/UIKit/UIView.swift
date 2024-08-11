import UIKit

extension UIView {
  public var parentViewController: UIViewController? {
    if let next = self.next as? UIViewController {
      return next
    } else if let next = self.next as? UIView {
      return next.parentViewController
    }

    return nil
  }
}
