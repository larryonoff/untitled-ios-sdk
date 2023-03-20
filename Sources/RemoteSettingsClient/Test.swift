import Dependencies
import XCTestDynamicOverlay

extension RemoteSettingsClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    fetch: unimplemented("\(Self.self).fetch"),
    registerDefaults: unimplemented("\(Self.self).registerDefaults"),
    boolForKey: unimplemented("\(Self.self).boolForKey", placeholder: nil),
    dataForKey: unimplemented("\(Self.self).dataForKey", placeholder: nil),
    doubleForKey: unimplemented("\(Self.self).doubleForKey", placeholder: nil),
    integerForKey: unimplemented("\(Self.self).integerForKey", placeholder: nil),
    stringForKey: unimplemented("\(Self.self).stringForKey", placeholder: nil),
    dictionaryRepresentation: unimplemented("\(Self.self).dictionaryRepresentation")
  )
}

extension RemoteSettingsClient {
  public static let noop = Self(
    fetch: { _ in },
    registerDefaults: { _ in },
    boolForKey: { _ in nil },
    dataForKey: { _ in nil },
    doubleForKey: { _ in nil },
    integerForKey: { _ in nil },
    stringForKey: { _ in nil },
    dictionaryRepresentation: { nil }
  )
}
