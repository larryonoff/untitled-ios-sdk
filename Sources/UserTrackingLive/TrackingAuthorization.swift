import AppTrackingTransparency
import DuckDependencies
import Sharing

/// The system boundaries of an ATT request; application-phase waiting stays shared with production.
struct TrackingAuthorization: Sendable {
  var phase: SharedReader<ApplicationPhase>
  var status: @Sendable () -> ATTrackingManager.AuthorizationStatus
  var request: @MainActor @Sendable () async -> ATTrackingManager.AuthorizationStatus

  static var system: Self {
    Self(
      phase: SharedReader(.applicationPhase),
      status: { ATTrackingManager.trackingAuthorizationStatus },
      request: { await ATTrackingManager.requestTrackingAuthorization() }
    )
  }
}
