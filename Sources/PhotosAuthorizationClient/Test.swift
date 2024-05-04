import Dependencies

extension PhotosAuthorizationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = PhotosAuthorizationClient()
}

extension PhotosAuthorizationClient {
  public static let noop = PhotosAuthorizationClient(
    authorizationStatus: { _ in .notDetermined },
    authorizationStatusUpdates: { _ in .finished },
    requestAuthorization: { _ in .notDetermined }
  )
}
