import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserSettingsClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    boolForKey: XCTUnimplemented("\(Self.self).boolForKey", placeholder: false),
    dataForKey: XCTUnimplemented("\(Self.self).dataForKey", placeholder: nil),
    doubleForKey: XCTUnimplemented("\(Self.self).doubleForKey", placeholder: 0),
    integerForKey: XCTUnimplemented("\(Self.self).integerForKey", placeholder: 0),
    remove: XCTUnimplemented("\(Self.self).remove"),
    setBool: XCTUnimplemented("\(Self.self).setBool"),
    setData: XCTUnimplemented("\(Self.self).setData"),
    setDouble: XCTUnimplemented("\(Self.self).setDouble"),
    setInteger: XCTUnimplemented("\(Self.self).setInteger")
  )
}

extension UserSettingsClient {
  public static let noop = Self(
    boolForKey: { _ in false },
    dataForKey: { _ in nil },
    doubleForKey: { _ in 0 },
    integerForKey: { _ in 0 },
    remove: { _ in },
    setBool: { _, _ in },
    setData: { _, _ in },
    setDouble: { _, _ in },
    setInteger: { _, _ in }
  )
}
