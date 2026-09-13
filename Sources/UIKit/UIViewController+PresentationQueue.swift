#if canImport(UIKit)

import Foundation
import UIKit

extension UIViewController {
  public static func presentInQueue(
    _ viewControllerToPresent: UIViewController,
    presentingViewController: @autoclosure @escaping @Sendable () -> UIViewController?,
    animated: Bool = true,
    completion: (@MainActor @Sendable (Bool) -> Void)? = nil
  ) {
    let presentOperation = BlockOperation {
      let semaphore = DispatchSemaphore(value: 0)

      OperationQueue.main.addOperation {
        // SAFETY: OperationQueue.main runs this block on the main thread.
        MainActor.assumeIsolated {
          guard let parent = presentingViewController() else {
            semaphore.signal()
            completion?(false)
            return
          }

          parent.present(
            viewControllerToPresent,
            animated: animated,
            after: semaphore,
            completion: completion
          )
        }
      }

      _ = semaphore.wait(timeout: .distantFuture)
    }

    let viewPointer = Unmanaged.passUnretained(viewControllerToPresent).toOpaque()
    presentOperation.name = "Present.\(viewPointer)"
    presentOperation.queuePriority = .veryHigh

    if let lastOperation = presentationQueue.operations.last {
      presentOperation.addDependency(lastOperation)
    }

    presentationQueue.addOperation(presentOperation)
  }

  public func dismissInQueue(
    animated: Bool = true,
    completion: (@MainActor @Sendable () -> Void)? = nil
  ) {
    let dismissOperation = BlockOperation {
      let semaphore = DispatchSemaphore(value: 0)

      OperationQueue.main.addOperation {
        // SAFETY: OperationQueue.main runs this block on the main thread.
        MainActor.assumeIsolated {
          self.dismiss(animated: animated) {
            semaphore.signal()
            completion?()
          }
        }
      }

      _ = semaphore.wait(timeout: .distantFuture)
    }

    let viewPointer = Unmanaged.passUnretained(self).toOpaque()
    dismissOperation.name = "Dismiss.\(viewPointer)"
    dismissOperation.queuePriority = .veryHigh

    if let lastOperation = presentationQueue.operations.last {
      dismissOperation.addDependency(lastOperation)
    }

    presentationQueue.addOperation(dismissOperation)
  }
}

private extension UIViewController {
  /// Presents once `self` is actually able to present.
  ///
  /// A controller that is mid-dismissal silently swallows `present(_:animated:)`: nothing
  /// appears, yet the completion reports success, so the caller's state says a screen is up
  /// that never arrived. Waiting for the dismissal to finish — via the transition
  /// coordinator, no swizzling needed — presents for real instead.
  ///
  /// The retry runs once. A presenter still unable to present after its own transition has
  /// ended is reported as a failure rather than retried again, so a controller that never
  /// settles cannot keep the queue's semaphore waiting forever.
  @MainActor
  func present(
    _ viewControllerToPresent: UIViewController,
    animated: Bool,
    after semaphore: DispatchSemaphore,
    completion: (@MainActor @Sendable (Bool) -> Void)?
  ) {
    guard isBeingDismissed, let coordinator = transitionCoordinator else {
      present(viewControllerToPresent, animated: animated) {
        semaphore.signal()
        completion?(true)
      }
      return
    }

    coordinator.animate(alongsideTransition: nil) { _ in
      // SAFETY: the transition coordinator calls its completion on the main thread.
      MainActor.assumeIsolated {
        guard !self.isBeingDismissed else {
          semaphore.signal()
          completion?(false)
          return
        }

        self.present(viewControllerToPresent, animated: animated) {
          semaphore.signal()
          completion?(true)
        }
      }
    }
  }
}

private let presentationQueue: OperationQueue = {
  let queue = OperationQueue()
  queue.maxConcurrentOperationCount = 1
  queue.name = "DuckSDK.UIViewController.PresentationQueue"
  return queue
}()

#endif
