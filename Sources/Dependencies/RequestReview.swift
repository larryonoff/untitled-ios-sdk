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
  static let liveValue = RequestReviewAction { @MainActor in
    if let activeScene = UIApplication.shared.activeScene {
      SKStoreReviewController.requestReview(in: activeScene)
    } else {
      SKStoreReviewController.requestReview()
    }

    return true
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
