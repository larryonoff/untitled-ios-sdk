import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserTrackingClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = UserTrackingClient(
    authorizationStatus: XCTUnimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
    authorizationStatusUpdates: XCTUnimplemented("\(Self.self).authorizationStatusUpdates", placeholder: .finished),
    initialize: XCTUnimplemented("\(Self.self).initialize"),
    isAuthorizationRequestNeeded: XCTUnimplemented("\(Self.self).isAuthorizationRequestNeeded", placeholder: false),
    requestAuthorization: XCTUnimplemented("\(Self.self).requestAuthorization", placeholder: .notDetermined)
  )
}

extension UserTrackingClient {
  public static let noop = UserTrackingClient(
    authorizationStatus: { .notDetermined },
    authorizationStatusUpdates: { AsyncStream { _ in } },
    initialize: {},
    isAuthorizationRequestNeeded: { false },
    requestAuthorization: { _ in .notDetermined }
  )
}
