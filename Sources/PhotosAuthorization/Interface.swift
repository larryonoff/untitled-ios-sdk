import Dependencies

extension DependencyValues {
  public var photosAuthorization: PhotosAuthorizationClient {
    get { self[PhotosAuthorizationClient.self] }
    set { self[PhotosAuthorizationClient.self] = newValue }
  }
}

public struct PhotosAuthorizationClient: Sendable {
  public var authorizationStatus: @Sendable (AccessLevel) -> AuthorizationStatus
  public var authorizationStatusUpdates: @Sendable (AccessLevel) -> AsyncStream<AuthorizationStatus>
  public var requestAuthorization: @Sendable (AccessLevel) async -> AuthorizationStatus
}

extension PhotosAuthorizationClient {
  public func requestAuthorizationIfNeeded(
    for acl: AccessLevel
  ) async -> AuthorizationStatus {
    let status = authorizationStatus(acl)

    guard status == .notDetermined else {
      return status
    }

    return await requestAuthorization(acl)
  }
}
