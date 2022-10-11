import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PhotosAuthorizationClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = PhotosAuthorizationClient(
    authorizationStatus: XCTUnimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
    authorizationStatusUpdates: XCTUnimplemented("\(Self.self).authorizationStatusUpdates", placeholder: .finished),
    requestAuthorization: XCTUnimplemented("\(Self.self).requestAuthorization", placeholder: .notDetermined)
  )
}

extension PhotosAuthorizationClient {
  public static let noop = PhotosAuthorizationClient(
    authorizationStatus: { _ in .notDetermined },
    authorizationStatusUpdates: { _ in AsyncStream { _ in } },
    requestAuthorization: { _ in .notDetermined }
  )
}
