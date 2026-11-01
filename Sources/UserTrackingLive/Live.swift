import AdServices
import AdSupport
import AppTrackingTransparency
import Combine
import ConcurrencyExtras
import DuckAnalyticsClient
import DuckDependencies
import DuckLogging
import DuckPurchasesClient
import DuckUserTracking
import Foundation
import OSLog
import Sharing

#if os(iOS)
import FacebookCore
import UIKit
#endif

extension UserTrackingClient {
  public static func live(
    analytics: AnalyticsClient,
    purchases: PurchasesClient
  ) -> Self {
    let impl = UserTrackingImpl(
      analytics: analytics,
      purchases: purchases
    )

    return UserTrackingClient(
      initialize: {
        impl.initialize()
      },
      authorizationStatus: {
        impl.authStatus
      },
      authorizationStatusUpdates: {
        impl.authStatusUpdates
      },
      isAuthorizationRequestNeeded: {
        impl.isAuthRequestNeeded()
      },
      requestAuthorization: { timeout in
        try await impl.requestAuthorization(
          timeoutWaitingForApplicationActive: timeout
        )
      },
      sendTrackingData: {
        await impl.sendTrackingData($0)
      },
      attributionToken: {
        try await Attribution.attributionToken()
      },
      identifierForAdvertising: {
        let identifierManager = ASIdentifierManager.shared()

        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
          return identifierManager.advertisingIdentifier
        }

        return nil
      },
      identifierForVendor: {
        #if os(iOS)
        await UIDevice.current.identifierForVendor
        #else
        // No macOS equivalent of `UIDevice.identifierForVendor`.
        nil
        #endif
      }
    )
  }
}

final class UserTrackingImpl: Sendable {
  private let analytics: AnalyticsClient
  private let purchases: PurchasesClient
  private let authorization: TrackingAuthorization
  // SAFETY: `CurrentValueSubject` is internally thread-safe; Combine just doesn't annotate it `Sendable`.
  // Seeded from the system rather than a literal: a guessed `.authorized` is
  // the one wrong answer that reads as permission the user never gave.
  private nonisolated(unsafe) let _authStatus: CurrentValueSubject<AuthorizationStatus, Never>

  init(
    analytics: AnalyticsClient,
    purchases: PurchasesClient,
    authorization: TrackingAuthorization = .system
  ) {
    self.analytics = analytics
    self.purchases = purchases
    self.authorization = authorization
    self._authStatus = CurrentValueSubject(AuthorizationStatus(authorization.status()))
  }

  var authStatus: AuthorizationStatus {
    _authStatus.value
  }

  var authStatusUpdates: AsyncStream<AuthorizationStatus> {
    // `CurrentValueSubject` replays its current value on subscribe, which is
    // the status as it already stands — not a change to it. Dropping it makes
    // this a stream of updates, as the name says; callers that want the
    // standing value read `authorizationStatus`.
    AsyncStream(UncheckedSendable(_authStatus.dropFirst().removeDuplicates().values))
  }

  func initialize() {
    updateAuthStatus(authorization.status())

    logger.info("user-tracking.initialize success")
  }

  func isAuthRequestNeeded() -> Bool {
    authorization.status() == .notDetermined
  }

  @MainActor
  func requestAuthorization(
    timeoutWaitingForApplicationActive timeout: Duration
  ) async throws -> AuthorizationStatus {
    logger.info("user-tracking.authorize")
    try Task.checkCancellation()

    guard isAuthRequestNeeded() else {
      let attStatus = authorization.status()
      let status = AuthorizationStatus(attStatus)

      logger.info(
        """
        user-tracking.authorize skipped | \
        status: \(status, privacy: .public) reason: not_needed
        """
      )

      return status
    }

    // The system only presents the ATT prompt while the app is active, and
    // requesting while it is not is worse than a no-op: no prompt is shown and
    // the completion is not always called back, which would leave this call —
    // and whatever awaits it — suspended for good. So the phase is a
    // precondition: wait for it, and report not getting there rather than
    // asking anyway. Authorization stays `.notDetermined`, so a later request
    // still gets to present the prompt.
    try await authorization.phase.wait(for: .active, timeout: timeout)
    try Task.checkCancellation()

    // Another request may have resolved while this caller waited for activation.
    let currentStatus = authorization.status()
    guard currentStatus == .notDetermined else {
      updateAuthStatus(currentStatus)
      return AuthorizationStatus(currentStatus)
    }

    // Logged only once the prompt can actually be presented, so the event
    // counts requests made rather than requests attempted.
    analytics.log(.idfaRequest)

    let attStatus = await authorization.request()
    let status = AuthorizationStatus(attStatus)

    updateAuthStatus(attStatus)

    analytics.log(
      .idfaResponse,
      parameters: [
        .status: status.description
      ]
    )

    logger.info(
      """
      user-tracking.authorize success | \
      status: \(status, privacy: .public)
      """
    )

    return status
  }

  func sendTrackingData(
    _ request: SendTrackingDataRequest
  ) async {
    logger.info("user-tracking.send")

    do {
      var identifiers = PurchasesClient.IntegrationIDs(
        appMetricaDeviceID: request.appMetricaDeviceID,
        appMetricaProfileID: request.appMetricaProfileID,
        firebaseAppInstanceID: request.firebaseAppInstanceID
      )
      #if os(iOS)
      identifiers.facebookAnonymousID = AppEvents.shared.anonymousID
      #endif
      try await purchases.setIntegrationIDs(identifiers)
      try await purchases.setTrackingAuthorizationStatus(authStatus.atAuthorizationStatus)

      logger.info("user-tracking.send success | target: purchases")
    } catch {
      logger.error(
        """
        user-tracking.send failed
        error: \(error, privacy: .public)
        """
      )
    }
  }

  private func updateAuthStatus(
    _ status: ATTrackingManager.AuthorizationStatus
  ) {
    _authStatus.value = .init(status)

    #if os(iOS)
    // `isAdvertiserTrackingEnabled` is not set: deprecated in iOS 17, where the
    // Facebook SDK reads `ATTrackingManager.trackingAuthorizationStatus` itself.
    FacebookCore.Settings.shared.isAdvertiserIDCollectionEnabled =
      status == .authorized
    #endif
  }
}

enum Attribution {
  typealias AttributionToken = String

  static func attributionToken(
  ) async throws -> AttributionToken? {
    #if targetEnvironment(simulator)
    debugPrint("WARNING: simulator freezes getting attributionToken, so its skipped")
    return nil
    #else
    return try AAAttribution.attributionToken()
    #endif
  }
}


let logger = Logger(
  subsystem: ".SDK.user-tracking",
  category: "UserTracking"
)
