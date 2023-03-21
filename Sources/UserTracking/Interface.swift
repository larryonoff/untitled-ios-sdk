import ComposableArchitecture
import Dependencies
import Foundation

extension DependencyValues {
  public var userTracking: UserTrackingClient {
    get { self[UserTrackingClient.self] }
    set { self[UserTrackingClient.self] = newValue }
  }
}

public struct UserTrackingClient {
  public var authorizationStatus: @Sendable () -> AuthorizationStatus
  public var authorizationStatusUpdates: @Sendable () -> AsyncStream<AuthorizationStatus>

  public var initialize: @Sendable () async -> Void

  public var isAuthorizationRequestNeeded: @Sendable () -> Bool

  public var requestAuthorization: @Sendable (Double) async -> AuthorizationStatus

  public var sendTrackingData: @Sendable () async -> Void

  public var identifierForAdvertising: @Sendable () async -> UUID?
  public var identifierForVendor: @Sendable () async -> UUID?
}
