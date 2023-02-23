import UIKit

extension UIViewController {
  public func embed(_ viewController: UIViewController) {
    let viewToEmbed = viewController.view!
    viewToEmbed.translatesAutoresizingMaskIntoConstraints = false
    viewToEmbed.frame = viewController.view.bounds

    addChild(viewController)
    view.addSubview(viewToEmbed)
    viewController.didMove(toParent: self)

    NSLayoutConstraint.activate([
      viewToEmbed.leftAnchor.constraint(equalTo: view.leftAnchor),
      viewToEmbed.rightAnchor.constraint(equalTo: view.rightAnchor),
      viewToEmbed.topAnchor.constraint(equalTo: view.topAnchor),
      viewToEmbed.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  public func unembed() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}
