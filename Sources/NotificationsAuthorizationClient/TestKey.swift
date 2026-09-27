import Dependencies

extension NotificationsAuthorizationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension NotificationsAuthorizationClient {
  public static let noop = Self(
    status: { .notDetermined },
    statusUpdates: { .finished },
    requestAuthorization: { _ in .notDetermined }
  )
}
