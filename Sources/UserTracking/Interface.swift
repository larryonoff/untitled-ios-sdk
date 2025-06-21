import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var userTracking: UserTrackingClient {
    get { self[UserTrackingClient.self] }
    set { self[UserTrackingClient.self] = newValue }
  }
}

@DependencyClient
public struct UserTrackingClient: Sendable {
  public var initialize: @Sendable () -> Void

  public var authorizationStatus: @Sendable (
  ) -> AuthorizationStatus = { .notDetermined }

  public var authorizationStatusUpdates: @Sendable (
  ) -> AsyncStream<AuthorizationStatus> = { .finished }

  public var isAuthorizationRequestNeeded: @Sendable (
  ) -> Bool = { true }

  public var requestAuthorization: @Sendable (
    Double
  ) async -> AuthorizationStatus = { _ in .notDetermined }

  public var sendTrackingData: @Sendable (
    _ request: SendTrackingDataRequest
  ) async -> Void

  public var attributionToken: @Sendable () async throws -> String?
  public var identifierForAdvertising: @Sendable () async -> UUID?
  public var identifierForVendor: @Sendable () async -> UUID?
}

public struct SendTrackingDataRequest: Equatable, Hashable, Sendable {
  public var appMetricaDeviceID: String?
  public var appMetricaProfileID: String?
  public var firebaseAppInstanceID: String?

  public var isForced: Bool

  public init(
    appMetricaDeviceID: String? = nil,
    appMetricaProfileID: String? = nil,
    firebaseAppInstanceID: String? = nil,
    isForced: Bool = false
  ) {
    self.appMetricaDeviceID = appMetricaDeviceID
    self.appMetricaProfileID = appMetricaProfileID
    self.firebaseAppInstanceID = firebaseAppInstanceID
    self.isForced = isForced
  }
}
