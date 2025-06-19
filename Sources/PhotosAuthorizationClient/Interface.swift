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
  ) -> PhotosAuthorization.AuthorizationStatus = { _ in .notDetermined }

  public var authorizationStatusUpdates: @Sendable (
    _ for: PhotosAuthorization.AccessLevel
  ) -> AsyncStream<PhotosAuthorization.AuthorizationStatus> = { _ in .finished }

  public var requestAuthorization: @Sendable (
    _ for: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus = { _ in .notDetermined }
}

extension PhotosAuthorizationClient {
  @Sendable
  public func requestAuthorizationIfNeeded(
    for acl: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus {
    let status = authorizationStatus(acl)

    guard status == .notDetermined else {
      return status
    }

    return await requestAuthorization(acl)
  }
}
