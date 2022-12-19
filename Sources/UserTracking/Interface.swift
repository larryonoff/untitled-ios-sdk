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

  public var requestAuthorization: @Sendable (UInt64) async -> AuthorizationStatus

  public var sendTrackingData: @Sendable () async -> Void
}

extension UserTrackingClient {
  public func requestAuthorization(
    delayFor interval: UInt64
  ) async -> AuthorizationStatus {
    await requestAuthorization(interval)
  }
}
