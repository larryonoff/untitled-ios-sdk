import ComposableArchitecture
@_exported import DuckPhotosAuthorizationClient

extension PersistenceReaderKey where Self == PhotosAuthorizationPersistenceKey {
  public static func photosAuthorization(
    _ accessLevel: PhotosAuthorization.AccessLevel
  ) -> Self {
    PhotosAuthorizationPersistenceKey(accessLevel: accessLevel)
  }

  public static var photosAuthorization: Self {
    PhotosAuthorizationPersistenceKey(accessLevel: .readWrite)
  }
}

public struct PhotosAuthorizationPersistenceKey: PersistenceReaderKey, Sendable {
  @Dependency(\.photosAuthorization) var photosAuthorization

  let accessLevel: PhotosAuthorization.AccessLevel

  public init(
    accessLevel: PhotosAuthorization.AccessLevel
  ) {
    self.accessLevel = accessLevel
  }

  public var id: AnyHashable {
    PhotosAuthorizationPersistenceKeyID(accessLevel: accessLevel)
  }

  public func load(
    initialValue: PhotosAuthorization.AuthorizationStatus?
  ) -> PhotosAuthorization.AuthorizationStatus? {
    photosAuthorization.authorizationStatus(accessLevel)
  }

  public func subscribe(
    initialValue: PhotosAuthorization.AuthorizationStatus?,
    didSet: @escaping (PhotosAuthorization.AuthorizationStatus?) -> Void
  ) -> Shared<PhotosAuthorization.AuthorizationStatus>.Subscription {
    let task = Task {
      for await purchases in self.photosAuthorization.authorizationStatusUpdates(accessLevel) {
        didSet(purchases)
      }
    }

    return Shared.Subscription {
      task.cancel()
    }
  }
}

private struct PhotosAuthorizationPersistenceKeyID: Hashable {
  let accessLevel: PhotosAuthorization.AccessLevel
}
