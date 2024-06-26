import Dependencies
import Foundation

extension DependencyValues {
  public var userTracking: UserTrackingClient {
    get { self[UserTrackingClient.self] }
    set { self[UserTrackingClient.self] = newValue }
  }
}

public struct UserTrackingClient: Sendable {
  public var initialize: @Sendable () -> Void

  public var authorizationStatus: @Sendable () -> AuthorizationStatus
  public var authorizationStatusUpdates: @Sendable () -> AsyncStream<AuthorizationStatus>

  public var isAuthorizationRequestNeeded: @Sendable () -> Bool

  public var requestAuthorization: @Sendable (Double) async -> AuthorizationStatus

  public var sendTrackingData: @Sendable () async -> Void

  public var attributionToken: @Sendable () async throws -> String?
  public var identifierForAdvertising: @Sendable () async -> UUID?
  public var identifierForVendor: @Sendable () async -> UUID?
}
