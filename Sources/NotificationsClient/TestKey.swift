import Dependencies

extension NotificationsClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension NotificationsClient {
  public static let noop = Self(
    activate: {},
    events: { .finished },
    addRequest: { _ in },
    removePendingRequestsWithIdentifiers: { _ in },
    removeDeliveredNotificationsWithIdentifiers: { _ in },
    setCategories: { _ in }
  )
}
