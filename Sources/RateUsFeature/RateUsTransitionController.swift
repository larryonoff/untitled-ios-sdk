import UIKit

final class RateUsTransitionController: NSObject {}

// MARK: - UIViewControllerTransitioningDelegate

extension RateUsTransitionController: UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> (any UIViewControllerAnimatedTransitioning)? {
    RateUsAnimationTransitionController(isPresentation: true)
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> (any UIViewControllerAnimatedTransitioning)? {
    RateUsAnimationTransitionController(isPresentation: false)
  }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension RateUsTransitionController: UIAdaptivePresentationControllerDelegate {
  func adaptivePresentationStyle(
    for controller: UIPresentationController,
    traitCollection: UITraitCollection
  ) -> UIModalPresentationStyle {
    .none
  }
}

final class RateUsAnimationTransitionController: NSObject {
  let isPresentation: Bool

  init(isPresentation: Bool) {
    self.isPresentation = isPresentation
    super.init()
  }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension RateUsAnimationTransitionController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(
    using transitionContext: (any UIViewControllerContextTransitioning)?
  ) -> TimeInterval {
    return 0.5
  }

  func animateTransition(
    using transitionContext: any UIViewControllerContextTransitioning
  ) {
    let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from

    guard
      let controller = transitionContext.viewController(forKey: key)
    else { return }

    if isPresentation {
      transitionContext.containerView.addSubview(controller.view)
    }

    let presentedFrame = transitionContext.finalFrame(for: controller)

    var dismissedFrame = presentedFrame
    dismissedFrame.origin.y = -presentedFrame.height

    let alphaFrom: CGFloat = isPresentation ? 0 : 1
    let alphaTo: CGFloat = isPresentation ? 1 : 0

    controller.view.frame = presentedFrame
    controller.view.alpha = alphaFrom

    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      delay: 0,
      usingSpringWithDamping: isPresentation ? 0.7 : 1.0,
      initialSpringVelocity: isPresentation ? 1 : 0.1,
      options: [.curveEaseInOut],
      animations: {
        controller.view.alpha = alphaTo
      },
      completion: { finished in
        if !self.isPresentation {
          controller.view.removeFromSuperview()
        }
        transitionContext.completeTransition(finished)
      }
    )
  }
}
