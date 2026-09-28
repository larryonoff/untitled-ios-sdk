#if canImport(UIKit)

import Foundation
import IssueReporting
import UIKit

extension UIViewController {
  public static func presentInQueue(
    _ viewControllerToPresent: UIViewController,
    presentingViewController: @autoclosure @escaping @MainActor @Sendable () -> UIViewController?,
    animated: Bool = true,
    completion: (@MainActor @Sendable (Bool) -> Void)? = nil
  ) {
    let presentOperation = BlockOperation {
      let semaphore = DispatchSemaphore(value: 0)

      OperationQueue.main.addOperation {
        // SAFETY: OperationQueue.main runs this block on the main thread.
        MainActor.assumeIsolated {
          @MainActor
          func present(isRetry: Bool) {
            guard let parent = presentingViewController(), !(isRetry && parent.isBeingDismissed) else {
              semaphore.signal()
              completion?(false)
              return
            }

            // A presenter on its way out swallows `present`: nothing appears, yet the
            // completion reports success. Wait for it to go, then ask again — the one
            // to present from is likely the controller it uncovers. Once only, so a
            // presenter that never settles cannot hold the queue.
            if !isRetry, parent.isBeingDismissed,
               parent.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                 // SAFETY: the transition coordinator calls its completion on the main thread.
                 MainActor.assumeIsolated { present(isRetry: true) }
               }) == true {
              return
            }

            parent.present(viewControllerToPresent, animated: animated) {
              semaphore.signal()
              completion?(true)
            }
          }

          present(isRetry: false)
        }
      }

      semaphore.waitForTransition("presenting \(type(of: viewControllerToPresent))")
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
          let finish = {
            semaphore.signal()
            completion?()
          }

          // Already gone — the person closed it, or UIKit took it down — so
          // `dismiss`'s completion may never run and the queue would wait forever.
          guard self.presentingViewController != nil || self.presentedViewController != nil else {
            finish()
            return
          }

          // On its way out already: a second `dismiss` may be dropped without its
          // completion, so wait for the running one to end instead.
          if self.isBeingDismissed {
            let isQueued = self.transitionCoordinator?.animate(alongsideTransition: nil) { context in
              // SAFETY: the transition coordinator calls its completion on the main thread.
              MainActor.assumeIsolated {
                // A swipe the person let go of leaves it on screen: dismiss it for real.
                if context.isCancelled {
                  self.dismiss(animated: animated, completion: finish)
                } else {
                  finish()
                }
              }
            }
            // Not queued, the completion never runs.
            if isQueued != true {
              finish()
            }
            return
          }

          self.dismiss(animated: animated, completion: finish)
        }
      }

      semaphore.waitForTransition("dismissing \(type(of: self))")
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

private extension DispatchSemaphore {
  /// Waits for a transition's completion, on the presentation queue — never the main
  /// thread — and never for good: UIKit drops the completion of a `present` or
  /// `dismiss` it refuses (a presenter out of the window, one already presenting), and
  /// one lost signal would hold back every presentation after it.
  ///
  /// ponytail: a fixed bound, far past any transition; a presentation still running
  /// when it lapses only lets the next one start early, which then waits on its own.
  func waitForTransition(_ transition: String) {
    if wait(timeout: .now() + .seconds(5)) == .timedOut {
      reportIssue("Presentation queue stopped waiting on \(transition) after 5 seconds")
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
