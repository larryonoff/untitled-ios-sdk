import Dependencies
import UIKit

extension DependencyValues {
  public var openSettings: OpenSettingsEffect {
    get { self[OpenSettingsKey.self] }
    set { self[OpenSettingsKey.self] = newValue }
  }

  private enum OpenSettingsKey: DependencyKey {
    static let liveValue = OpenSettingsEffect {
      #if os(iOS)
        await MainActor.run {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
