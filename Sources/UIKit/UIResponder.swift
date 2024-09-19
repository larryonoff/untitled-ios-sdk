import UIKit

extension UIResponder {
  var _parentViewController: UIViewController? {
    next as? UIViewController ?? next?._parentViewController
  }
}
