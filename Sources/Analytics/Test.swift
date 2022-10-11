import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension Analytics: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Analytics(
    log: XCTUnimplemented("\(Self.self).log"),
    setUserProperty: XCTUnimplemented("\(Self.self).setUserProperty")
  )
}

extension Analytics {
  public static let noop = Analytics(
    log: { _ in },
    setUserProperty: { _, _ in }
  )
}
