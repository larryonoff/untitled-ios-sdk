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

  /// Requests ATT authorization, waiting up to the given timeout for the app to
  /// become foreground-active before presenting the system prompt.
  ///
  /// The prompt is only shown while the app is active, and requesting while it
  /// is not is worse than a no-op: no prompt appears and the system does not
  /// always call back, which would leave the call suspended for good. Pass
  /// `.zero` only when the app is already known to be active.
  ///
  /// - Throws: ``ApplicationPhase/TimeoutError`` if the app is not active by
  ///   the time the timeout elapses.
  public var requestAuthorization: @Sendable (
    _ timeoutWaitingForApplicationActive: Duration
  ) async throws -> AuthorizationStatus

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
