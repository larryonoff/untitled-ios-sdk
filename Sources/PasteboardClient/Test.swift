import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PasteboardClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    setString: unimplemented("\(Self.self).setString")
  )
}

extension PasteboardClient {
  public static let noop = Self(
    setString: { _ in }
  )
}
