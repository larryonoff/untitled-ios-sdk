import ComposableArchitecture
import Photos

extension PhotosAuthorizationClient {
  public static let live: Self = {
    let authorizationPipe = AsyncStream<(AccessLevel, AuthorizationStatus)>
      .streamWithContinuation((AccessLevel, AuthorizationStatus).self)

    return PhotosAuthorizationClient(
      authorizationStatus: { acl in
        PhotosAuthorizationClient.authorizationStatus(for: acl)
      },
      authorizationStatusUpdates: { acl in
        AsyncStream(
          authorizationPipe.stream
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
          authorizationPipe.continuation.yield((acl, newStatus))
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
