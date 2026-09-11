import Dependencies

extension NotificationsAuthorizationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = NotificationsAuthorizationClient()
}

extension NotificationsAuthorizationClient {
  public static let noop = NotificationsAuthorizationClient(
    status: { .notDetermined },
    requestAuthorization: { false }
  )
}
