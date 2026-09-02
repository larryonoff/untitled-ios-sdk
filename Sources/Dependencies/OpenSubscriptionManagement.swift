import Dependencies
import IssueReporting
import DuckUIKit
import StoreKit
import SwiftUI

extension DependencyValues {
  public var openSubscriptionManagement: OpenSubscriptionManagementEffect {
    get { self[OpenSubscriptionManagementKey.self] }
    set { self[OpenSubscriptionManagementKey.self] = newValue }
  }
}

private enum OpenSubscriptionManagementKey: DependencyKey {
  static let liveValue = OpenSubscriptionManagementEffect { @MainActor in
    #if canImport(UIKit)
      if let activeScene = UIApplication.shared.activeScene {
        do {
          try await AppStore.showManageSubscriptions(in: activeScene)
          return
        } catch {
          // Fall through to the App Store subscriptions page.
          reportIssue(error)
        }
      }
    #endif

    EnvironmentValues().openURL(
      URL(string: "https://apps.apple.com/account/subscriptions")!
    )
  }

  static let testValue = OpenSubscriptionManagementEffect(
    handler: unimplemented(#"@Dependency(\.openSubscriptionManagement)"#)
  )
}

public struct OpenSubscriptionManagementEffect: Sendable {
  private let handler: @Sendable () async -> Void

  public init(handler: @escaping @Sendable () async -> Void) {
    self.handler = handler
  }

  public func callAsFunction() async {
    await self.handler()
  }
}
