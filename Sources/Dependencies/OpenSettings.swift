import Dependencies

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension DependencyValues {
  public var openSettings: OpenSettingsEffect {
    get { self[OpenSettingsKey.self] }
    set { self[OpenSettingsKey.self] = newValue }
  }

  private enum OpenSettingsKey: DependencyKey {
    static let liveValue = OpenSettingsEffect {
      #if canImport(UIKit)
        await MainActor.run {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
      #else
        await MainActor.run {
          _ = NSWorkspace.shared.open(
            URL(string: "x-apple.systempreferences:com.apple.preference.security")!
          )
        }
      #endif
    }

    static let testValue = OpenSettingsEffect {
      XCTFail(#"Unimplemented: @Dependency(\.openSettings)"#)
    }
  }
}

public struct OpenSettingsEffect: Sendable {
  private let handler: @Sendable () async -> Void

  public init(handler: @escaping @Sendable () async -> Void) {
    self.handler = handler
  }

  public func callAsFunction() async {
    _ = await self.handler()
  }
}
