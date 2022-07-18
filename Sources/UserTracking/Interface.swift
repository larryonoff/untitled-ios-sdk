import Combine
import ComposableArchitecture
import Foundation

public struct UserTrackingClient {
  public var authorizationStatus: () -> ATTrackingManager.AuthorizationStatus
  public var authorizationStatusValues: () -> Effect<ATTrackingManager.AuthorizationStatus, Never>

  public var initialize: () -> Void

  public var isAuthorizationRequestNeeded: () -> Bool

  public var requestAuthorization: (UInt64) async -> ATTrackingManager.AuthorizationStatus

  public init(
    authorizationStatus: @escaping () -> ATTrackingManager.AuthorizationStatus,
    authorizationStatusValues: @escaping () -> Effect<ATTrackingManager.AuthorizationStatus, Never>,
    initialize: @escaping () -> Void,
    isAuthorizationRequestNeeded: @escaping () -> Bool,
    requestAuthorization: @escaping (UInt64) async -> ATTrackingManager.AuthorizationStatus
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
  ) async -> ATTrackingManager.AuthorizationStatus {
    await requestAuthorization(interval)
  }
}
