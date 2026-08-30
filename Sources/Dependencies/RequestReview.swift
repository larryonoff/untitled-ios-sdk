import Dependencies
import IssueReporting
import DuckUIKit
import StoreKit
import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

extension DependencyValues {
  public var requestReview: RequestReviewAction {
    get { self[RequestReviewKey.self] }
    set { self[RequestReviewKey.self] = newValue }
  }
}

private enum RequestReviewKey: DependencyKey {
  static let liveValue = RequestReviewAction { @MainActor in
#if canImport(UIKit)
    guard let activeScene = UIApplication.shared.activeScene else {
      return false
    }
    AppStore.requestReview(in: activeScene)
    return true
#else
    guard
      let controller = NSApplication.shared.keyWindow?.contentViewController
    else {
      return false
    }
    AppStore.requestReview(in: controller)
    return true
#endif
  }

  static let testValue = RequestReviewAction(
    handler: unimplemented(#"@Dependency(\.requestReview)"#, placeholder: false)
  )
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
