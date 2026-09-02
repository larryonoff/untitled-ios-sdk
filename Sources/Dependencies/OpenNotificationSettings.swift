import Dependencies
import IssueReporting

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension DependencyValues {
  public var openNotificationSettings: OpenNotificationSettingsEffect {
    get { self[OpenNotificationSettingsKey.self] }
    set { self[OpenNotificationSettingsKey.self] = newValue }
  }
}

private enum OpenNotificationSettingsKey: DependencyKey {
  static let liveValue = OpenNotificationSettingsEffect { @MainActor in
    #if canImport(UIKit)
      UIApplication.shared.open(
        URL(string: UIApplication.openNotificationSettingsURLString)!
      )
    #else
      _ = NSWorkspace.shared.open(
        URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!
      )
    #endif
  }

  static let testValue = OpenNotificationSettingsEffect(
    handler: unimplemented(#"@Dependency(\.openNotificationSettings)"#)
  )
}

public struct OpenNotificationSettingsEffect: Sendable {
  private let handler: @Sendable () async -> Void

  public init(handler: @escaping @Sendable () async -> Void) {
    self.handler = handler
  }

  public func callAsFunction() async {
    await self.handler()
  }
}
