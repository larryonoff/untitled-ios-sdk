import Combine
import Dependencies
import DuckLogging
import Photos

extension PhotosAuthorizationClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = PhotosAuthorizationClientImpl()

    return Self(
      authorizationStatus: {
        impl.authorizationStatus(for: $0)
      },
      authorizationStatusUpdates: {
        impl.authorizationStatusUpdates(for: $0)
      },
      requestAuthorization: {
        await impl.requestAuthorizationIfNeeded(for: $0)
      }
    )
  }()
}

private final actor PhotosAuthorizationClientImpl {
  init() {}

  private let authorizationSubject =
    PassthroughSubject<
      (PhotosAuthorization.AccessLevel, PhotosAuthorization.AuthorizationStatus),
      Never
    >()

  nonisolated func authorizationStatus(
    for acl: PhotosAuthorization.AccessLevel
  ) -> PhotosAuthorization.AuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus(
      for: acl.phAccessLevel
    )
    return PhotosAuthorization.AuthorizationStatus(status)
  }

  nonisolated func authorizationStatusUpdates(
    for acl: PhotosAuthorization.AccessLevel
  ) -> AsyncStream<PhotosAuthorization.AuthorizationStatus> {
    authorizationSubject.values
      .filter { $0.0 == acl }
      .map { $0.1 }
      .eraseToStream()
  }

  @MainActor
  func requestAuthorizationIfNeeded(
    for acl: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus {
    logger.info("request authorization", dump: [
      "acl": acl
    ])

    let previousStatus = authorizationStatus(for: acl)

    let newStatus = PhotosAuthorization.AuthorizationStatus(
      await PHPhotoLibrary.requestAuthorization(
        for: acl.phAccessLevel
      )
    )

    if previousStatus != newStatus {
      authorizationSubject.send((acl, newStatus))
    }

    logger.info("request authorization success", dump: [
      "acl": acl,
      "status": newStatus,
      "updated": previousStatus != newStatus
    ])

    return newStatus
  }
}

let logger = Logger(
  subsystem: ".SDK.PhotosAuthorizationClient",
  category: "Photos"
)
