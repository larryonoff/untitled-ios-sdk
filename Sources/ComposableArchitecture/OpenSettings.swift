import Dependencies
import IssueReporting

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension DependencyValues {
  public var openSettings: @Sendable () async -> Void {
    get { self[OpenSettingsKey.self] }
    set { self[OpenSettingsKey.self] = newValue }
  }

  private enum OpenSettingsKey: DependencyKey {
    typealias Value = @Sendable () async -> Void

    static let liveValue: Value = {
      await MainActor.run {
#if canImport(UIKit)
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
#elseif canImport(AppKit)
        _ = NSWorkspace.shared.open(
          URL(string: "x-apple.systempreferences:com.apple.preference.security")!
        )
#endif
      }
    }

    static let testValue: Value = unimplemented(
      #"@Dependency(\.openSettings)"#
    )
  }
}
