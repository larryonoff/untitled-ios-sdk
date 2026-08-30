import Dependencies

extension RemoteSettingsClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
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
