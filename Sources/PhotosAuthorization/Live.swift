import Combine
import ComposableArchitecture
import Dependencies
import Photos

extension PhotosAuthorizationClient: DependencyKey {
  public static let liveValue: Self = {
    let authorizationSubject =
      PassthroughSubject<(AccessLevel, AuthorizationStatus), Never>()

    return PhotosAuthorizationClient(
      authorizationStatus: { acl in
        PhotosAuthorizationClient.authorizationStatus(for: acl)
      },
      authorizationStatusUpdates: { acl in
        AsyncStream(
          authorizationSubject.values
            .filter { $0.0 == acl }
            .map { $0.1 }
        )
      },
      requestAuthorization: { acl in
        let oldStatus =
            PhotosAuthorizationClient.authorizationStatus(for: acl)

        let newStatus = AuthorizationStatus(
          await PHPhotoLibrary.requestAuthorization(
            for: acl.phAccessLevel
          )
        )

        if oldStatus != newStatus {
          authorizationSubject.send((acl, newStatus))
        }

        return newStatus
      }
    )
  }()
}

extension PhotosAuthorizationClient {
  static func authorizationStatus(
    for acl: AccessLevel
  ) -> AuthorizationStatus {
    return AuthorizationStatus(
      PHPhotoLibrary.authorizationStatus(
        for: acl.phAccessLevel
      )
    )
  }
}
