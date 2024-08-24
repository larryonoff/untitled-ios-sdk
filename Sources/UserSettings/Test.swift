import Dependencies
import Foundation

extension UserSettingsClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension UserSettingsClient {
  public static let noop = Self(
    boolForKey: { _ in false },
    dataForKey: { _ in nil },
    doubleForKey: { _ in 0 },
    integerForKey: { _ in 0 },
    removeValueForKey: { _ in },
    setBool: { _, _ in },
    setData: { _, _ in },
    setDouble: { _, _ in },
    setInteger: { _, _ in }
  )
}
