import ComposableArchitecture
@_exported import DuckPhotosAuthorizationClient

extension SharedReaderKey where Self == PhotosAuthorizationPersistenceKey {
  public static func photosAuthorization(
    _ accessLevel: PhotosAuthorization.AccessLevel
  ) -> Self {
    PhotosAuthorizationPersistenceKey(accessLevel: accessLevel)
  }

  public static var photosAuthorization: Self {
    PhotosAuthorizationPersistenceKey(accessLevel: .readWrite)
  }
}

public struct PhotosAuthorizationPersistenceKey: SharedReaderKey, Sendable {
  @Dependency(\.photosAuthorization) var photosAuthorization

  let accessLevel: PhotosAuthorization.AccessLevel

  public init(
    accessLevel: PhotosAuthorization.AccessLevel
  ) {
    self.accessLevel = accessLevel
  }

  public var id: PhotosAuthorizationPersistenceKeyID {
    PhotosAuthorizationPersistenceKeyID(accessLevel: accessLevel)
  }

  public func load(
    context: LoadContext<PhotosAuthorization.AuthorizationStatus>,
    continuation: LoadContinuation<PhotosAuthorization.AuthorizationStatus>
  ) {
    continuation.resume(
      with: .success(photosAuthorization.authorizationStatus(accessLevel))
    )
  }

  public func subscribe(
    context: LoadContext<PhotosAuthorization.AuthorizationStatus>,
    subscriber: SharedSubscriber<PhotosAuthorization.AuthorizationStatus>
  ) -> SharedSubscription {
    let task = Task {
      for await status in self.photosAuthorization.authorizationStatusUpdates(accessLevel) {
        subscriber.yield(status)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct PhotosAuthorizationPersistenceKeyID: Hashable {
  let accessLevel: PhotosAuthorization.AccessLevel
}
