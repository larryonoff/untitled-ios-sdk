import Foundation
import UIKit

extension UIViewController {
  public static func presentInQueue(
    _ viewControllerToPresent: UIViewController,
    presentingViewController: @autoclosure @escaping () -> UIViewController?,
    animated: Bool = true,
    completion: ((Bool) -> Void)? = nil
  ) {
    let presentOperation = BlockOperation {
      let semaphore = DispatchSemaphore(value: 0)

      OperationQueue.main.addOperation {
        guard let parent = presentingViewController() else {
          semaphore.signal()
          completion?(false)
          return
        }

        parent.present(
          viewControllerToPresent,
          animated: animated,
          completion: {
            semaphore.signal()
            completion?(true)
          }
        )
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
    completion: (() -> Void)? = nil
  ) {
    let dismissOperation = BlockOperation {
      let semaphore = DispatchSemaphore(value: 0)

      OperationQueue.main.addOperation {
        self.dismiss(animated: animated) {
          semaphore.signal()
          completion?()
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

private let presentationQueue: OperationQueue = {
  let queue = OperationQueue()
  queue.maxConcurrentOperationCount = 1
  queue.name = "DuckSDK.UIViewController.PresentationQueue"
  return queue
}()
