import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserTrackingClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = UserTrackingClient(
    authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
    authorizationStatusUpdates: unimplemented("\(Self.self).authorizationStatusUpdates", placeholder: .finished),
    initialize: unimplemented("\(Self.self).initialize"),
    isAuthorizationRequestNeeded: unimplemented("\(Self.self).isAuthorizationRequestNeeded", placeholder: false),
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization", placeholder: .notDetermined),
    sendTrackingData: unimplemented("\(Self.self).sendTrackingData"),
    attributionToken: unimplemented("\(Self.self).attributionToken", placeholder: nil),
    identifierForAdvertising: unimplemented("\(Self.self).identifierForAdvertising", placeholder: nil),
    identifierForVendor: unimplemented("\(Self.self).identifierForVendor", placeholder: nil)
  )
}

extension UserTrackingClient {
  public static let noop = UserTrackingClient(
    authorizationStatus: { .notDetermined },
    authorizationStatusUpdates: { AsyncStream { _ in } },
    initialize: {},
    isAuthorizationRequestNeeded: { false },
    requestAuthorization: { _ in .notDetermined },
    sendTrackingData: {},
    attributionToken: { nil },
    identifierForAdvertising: { nil },
    identifierForVendor: { nil }
  )
}
