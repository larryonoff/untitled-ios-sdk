import Dependencies
import XCTestDynamicOverlay

extension PhotosAuthorizationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = PhotosAuthorizationClient(
    authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
    authorizationStatusUpdates: unimplemented("\(Self.self).authorizationStatusUpdates", placeholder: .finished),
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization", placeholder: .notDetermined)
  )
}

extension PhotosAuthorizationClient {
  public static let noop = PhotosAuthorizationClient(
    authorizationStatus: { _ in .notDetermined },
    authorizationStatusUpdates: { _ in AsyncStream { _ in } },
    requestAuthorization: { _ in .notDetermined }
  )
}
