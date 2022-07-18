import Combine
import ComposableArchitecture
import Foundation

public struct UserTrackingClient {
  public var authorizationStatus: () -> AuthorizationStatus
  public var authorizationStatusValues: () -> Effect<AuthorizationStatus, Never>

  public var initialize: () -> Void

  public var isAuthorizationRequestNeeded: () -> Bool

  public var requestAuthorization: (UInt64) async -> AuthorizationStatus

  public init(
    authorizationStatus: @escaping () -> AuthorizationStatus,
    authorizationStatusValues: @escaping () -> Effect<AuthorizationStatus, Never>,
    initialize: @escaping () -> Void,
    isAuthorizationRequestNeeded: @escaping () -> Bool,
    requestAuthorization: @escaping (UInt64) async -> AuthorizationStatus
  ) {
    self.authorizationStatus = authorizationStatus
    self.authorizationStatusValues = authorizationStatusValues
    self.initialize = initialize
    self.isAuthorizationRequestNeeded = isAuthorizationRequestNeeded
    self.requestAuthorization = requestAuthorization
  }
}

extension UserTrackingClient {
  public func requestAuthorization(
    delayFor interval: UInt64
  ) async -> AuthorizationStatus {
    await requestAuthorization(interval)
  }
}
