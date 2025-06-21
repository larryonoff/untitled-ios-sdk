import Dependencies
import Foundation

extension UserTrackingClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = UserTrackingClient()
}

extension UserTrackingClient {
  public static let noop = UserTrackingClient(
    initialize: {},
    authorizationStatus: { .notDetermined },
    authorizationStatusUpdates: { AsyncStream { _ in } },
    isAuthorizationRequestNeeded: { false },
    requestAuthorization: { _ in .notDetermined },
    sendTrackingData: { _ in },
    attributionToken: { nil },
    identifierForAdvertising: { nil },
    identifierForVendor: { nil }
  )
}
