import Dependencies

extension UserAttributionClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension UserAttributionClient {
  public static let noop = Self(
    initialize: { _ in },
    delegate: { .finished },
    logTransaction: { _ in },
    uid: { nil },
    reset: {}
  )
}
