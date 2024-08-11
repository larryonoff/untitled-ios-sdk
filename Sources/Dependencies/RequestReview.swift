import Dependencies
import DuckUIKit
import StoreKit
import SwiftUI

extension DependencyValues {
  public var requestReview: RequestReviewAction {
    get { self[RequestReviewKey.self] }
    set { self[RequestReviewKey.self] = newValue }
  }
}

private enum RequestReviewKey: DependencyKey {
  static let liveValue = RequestReviewAction {
    let stream = AsyncStream<Bool> { continuation in
      let task = Task { @MainActor in
        if #available(iOS 16.0, *) {
          EnvironmentValues().requestReview()
          continuation.yield(true)
          continuation.finish()
        } else {
          if let activeScene = UIApplication.shared.activeScene {
            SKStoreReviewController.requestReview(in: activeScene)
          } else {
            SKStoreReviewController.requestReview()
          }

          continuation.yield(false)
          continuation.finish()
        }
      }

      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }

    return await stream.first(where: { _ in true }) ?? false
  }

  static let testValue = RequestReviewAction {
    XCTFail(#"Unimplemented: @Dependency(\.requestReview)"#)
    return false
  }
}

public struct RequestReviewAction: Sendable {
  private let handler: @Sendable () async -> Bool

  public init(handler: @escaping @Sendable () async -> Bool) {
    self.handler = handler
  }

  public func callAsFunction() async -> Bool {
    await self.handler()
  }
}
