import Adapty
import AdServices
import AdSupport
import AppTrackingTransparency
import Combine
import ConcurrencyExtras
import DuckAnalyticsClient
import DuckLogging
import FirebaseAnalytics
import Foundation
import OSLog

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
      requestAuthorization: { dueTime in
        await impl.requestAuthorization(delayFor: dueTime)
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
  private nonisolated(unsafe) let _authStatus = CurrentValueSubject<AuthorizationStatus, Never>(.authorized)

  init(
    analytics: AnalyticsClient
  ) {
    self.analytics = analytics
  }

  var authStatus: AuthorizationStatus {
    _authStatus.value
  }

  var authStatusUpdates: AsyncStream<AuthorizationStatus> {
    AsyncStream(UncheckedSendable(_authStatus.removeDuplicates().values))
  }

  func initialize() {
    updateAuthStatus(
      ATTrackingManager.trackingAuthorizationStatus
    )

    logger.info("initialize success")
  }

  func isAuthRequestNeeded() -> Bool {
    ATTrackingManager.trackingAuthorizationStatus == .notDetermined
  }

  func requestAuthorization(
    delayFor interval: Double
  ) async -> AuthorizationStatus {
    logger.info("request authorization")

    guard isAuthRequestNeeded() else {
      let attStatus = ATTrackingManager.trackingAuthorizationStatus
      let status = AuthorizationStatus(attStatus)

      logger.info("request authorization not needed", dump: [
        "status": status
      ])

      return status
    }

    analytics.log(.idfaRequest)

    if interval > 0 {
      try? await Task.sleep(for: .seconds(interval))
    }

    let attStatus = await ATTrackingManager.requestTrackingAuthorization()
    let status = AuthorizationStatus(attStatus)

    updateAuthStatus(attStatus)

    analytics.log(
      .idfaResponse,
      parameters: [
        .status: status.description
      ]
    )

    logger.info("authorization request success", dump: [
      "status": status
    ])

    return status
  }

  func sendTrackingData(
    _ request: SendTrackingDataRequest
  ) async {
    logger.info("send tracking data")

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
          logger.info("send tracking key-value: \(identifier.key)-\(identifier.value)", dump: [
            "target": "Adapty"
          ])

          try await Adapty.setIntegrationIdentifier(identifier)
        } catch {
          logger.error("send tracking key-value: \(identifier.key):\(identifier.value) failed", dump: [
            "target": "Adapty",
            "error": error.localizedDescription
          ])
        }
      }

      let params = AdaptyProfileParameters.Builder()
        .with(appTrackingTransparencyStatus: authStatus.atAuthorizationStatus)
        .build()

      try await Adapty.updateProfile(params: params)

      logger.info("send tracking data success")
    } catch {
      logger.error("send tracking data failure", dump: [
        "error": error.localizedDescription
      ])
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
