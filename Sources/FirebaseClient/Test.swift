import Dependencies

extension FirebaseClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension FirebaseClient {
  public static let noop = Self(
    initialize: {},
    recordError: { _, _ in },
    reset: {}
  )
}
