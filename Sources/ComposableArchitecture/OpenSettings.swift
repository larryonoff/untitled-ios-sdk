import Dependencies
import UIKit

extension DependencyValues {
  public var openSettings: @Sendable () async -> Void {
    get { self[OpenSettingsKey.self] }
    set { self[OpenSettingsKey.self] = newValue }
  }

  private enum OpenSettingsKey: DependencyKey {
    typealias Value = @Sendable () async -> Void

    static let liveValue: Value = {
      await MainActor.run {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      }
    }

    static let testValue: Value = {
      XCTFail(#"Unimplemented: @Dependency(\.openSettings)"#)
      return
    }
  }
}
