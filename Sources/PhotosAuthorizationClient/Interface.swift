import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var photosAuthorization: PhotosAuthorizationClient {
    get { self[PhotosAuthorizationClient.self] }
    set { self[PhotosAuthorizationClient.self] = newValue }
  }
}

@DependencyClient
public struct PhotosAuthorizationClient: Sendable {
  public var authorizationStatus: @Sendable (
    _ for: PhotosAuthorization.AccessLevel
  ) -> PhotosAuthorization.AuthorizationStatus

  public var authorizationStatusUpdates: @Sendable (
    _ for: PhotosAuthorization.AccessLevel
  ) -> AsyncStream<PhotosAuthorization.AuthorizationStatus>

  public var requestAuthorization: @Sendable (
    _ for: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus
}

extension PhotosAuthorizationClient {
  public func requestAuthorizationIfNeeded(
    for acl: AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus {
    let status = authorizationStatus(acl)

    guard status == .notDetermined else {
      return status
    }

    return await requestAuthorization(acl)
  }
}
