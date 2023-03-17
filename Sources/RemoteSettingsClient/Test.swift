import Dependencies
import XCTestDynamicOverlay

extension RemoteSettingsClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    fetch: unimplemented("\(Self.self).fetch"),
    registerDefaults: unimplemented("\(Self.self).registerDefaults"),
    boolForKey: unimplemented("\(Self.self).boolForKey"),
    dataForKey: unimplemented("\(Self.self).dataForKey"),
    doubleForKey: unimplemented("\(Self.self).doubleForKey"),
    integerForKey: unimplemented("\(Self.self).integerForKey"),
    stringForKey: unimplemented("\(Self.self).stringForKey"),
    dictionaryRepresentation: unimplemented("\(Self.self).dictionaryRepresentation")
  )
}

extension RemoteSettingsClient {
  public static let noop = Self(
    fetch: { _ in },
    registerDefaults: { _ in },
    boolForKey: { _ in false },
    dataForKey: { _ in nil },
    doubleForKey: { _ in 0 },
    integerForKey: { _ in 0 },
    stringForKey: { _ in nil },
    dictionaryRepresentation: { nil }
  )
}
