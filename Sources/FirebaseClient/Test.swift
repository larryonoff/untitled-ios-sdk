import Dependencies

extension FirebaseClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension FirebaseClient {
  public static let noop = Self(
    appInstanceID: { nil },
    logEvent: { _, _ in },
    logMessage: { _ in },
    recordError: { _, _ in },
    reset: {}
  )
}
