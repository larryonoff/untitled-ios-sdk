import Combine
import ComposableArchitecture
import Foundation

public struct UserTrackingClient {
  public var authorizationStatus: () -> AuthorizationStatus
  public var authorizationStatusValues: () -> Effect<AuthorizationStatus, Never>

  public var initialize: () -> Void

  public var isAuthorizationRequestNeeded: () -> Bool

  public var requestAuthorization: (UInt64) async -> AuthorizationStatus
}

extension UserTrackingClient {
  public func requestAuthorization(
    delayFor interval: UInt64
  ) async -> AuthorizationStatus {
    await requestAuthorization(interval)
  }
}
