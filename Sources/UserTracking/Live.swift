import Adapty
import AdServices
import AdSupport
import AppTrackingTransparency
import Combine
import ConcurrencyExtras
import DuckAnalyticsClient
import DuckDependencies
import DuckLogging
import FirebaseAnalytics
import Foundation
import OSLog
import Sharing

#if os(iOS)
import FacebookCore
import UIKit
#endif

extension UserTrackingClient {
  public static func live(
    analytics: AnalyticsClient
  ) -> Self {
    let impl = UserTrackingImpl(
      analytics: analytics
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
  // SAFETY: `CurrentValueSubject` is internally thread-safe; Combine just doesn't annotate it `Sendable`.
  // Seeded from the system rather than a literal: a guessed `.authorized` is
  // the one wrong answer that reads as permission the user never gave.
  private nonisolated(unsafe) let _authStatus = CurrentValueSubject<AuthorizationStatus, Never>(
    AuthorizationStatus(ATTrackingManager.trackingAuthorizationStatus)
  )

  init(
    analytics: AnalyticsClient
  ) {
    self.analytics = analytics
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
    updateAuthStatus(
      ATTrackingManager.trackingAuthorizationStatus
    )

    logger.info("user-tracking.initialize success")
  }

  func isAuthRequestNeeded() -> Bool {
    ATTrackingManager.trackingAuthorizationStatus == .notDetermined
  }

  func requestAuthorization(
    timeoutWaitingForApplicationActive timeout: Duration
  ) async throws -> AuthorizationStatus {
    logger.info("user-tracking.authorize")

    guard isAuthRequestNeeded() else {
      let attStatus = ATTrackingManager.trackingAuthorizationStatus
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
    @SharedReader(.applicationPhase) var phase
    try await $phase.wait(for: .active, timeout: timeout)

    // Logged only once the prompt can actually be presented, so the event
    // counts requests made rather than requests attempted.
    analytics.log(.idfaRequest)

    let attStatus = await ATTrackingManager.requestTrackingAuthorization()
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
      var intergrationIDs: [AdaptyIntegrationIdentifier] = [
        request.appMetricaDeviceID.map(AdaptyIntegrationIdentifier.appmetricaDeviceId),
        request.appMetricaProfileID.map(AdaptyIntegrationIdentifier.appmetricaProfileId),
        request.firebaseAppInstanceID.map(AdaptyIntegrationIdentifier.firebaseAppInstanceId)
      ].compactMap { $0 }

#if os(iOS)
      intergrationIDs.append(.facebookAnonymousId(AppEvents.shared.anonymousID))
#endif

      for identifier in intergrationIDs {
        do {
          // Only the key is logged: the value is the advertising, vendor or
          // profile identifier itself, and the system log is not a place to
          // put one.
          logger.info(
            """
            user-tracking.send-identifier | \
            key: \(identifier.key, privacy: .public) target: Adapty
            """
          )

          try await Adapty.setIntegrationIdentifier(identifier)
        } catch {
          logger.error(
            """
            user-tracking.send-identifier failed | \
            key: \(identifier.key, privacy: .public) target: Adapty
            error: \(error, privacy: .public)
            """
          )
        }
      }

      let params = AdaptyProfileParameters.Builder()
        .with(appTrackingTransparencyStatus: authStatus.atAuthorizationStatus)
        .build()

      try await Adapty.updateProfile(params: params)

      logger.info("user-tracking.send success")
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
