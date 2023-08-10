import Adapty
import AdServices
import AdSupport
import Amplitude
import AnalyticsClient
import AppTrackingTransparency
import Combine
import FacebookCore
import FirebaseAnalytics
import Foundation
import LoggingSupport
import OSLog
import UIKit

public typealias Analytics = AnalyticsClient.Analytics

extension UserTrackingClient {
  public static func live(
    analytics: Analytics
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
        await impl.sendTrackingData()
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
        await UIDevice.current.identifierForVendor
      }
    )
  }
}

final actor UserTrackingImpl {
  private let analytics: Analytics

  init(
    analytics: Analytics
  ) {
    self.analytics = analytics
  }

  private let _authStatus = CurrentValueSubject<AuthorizationStatus, Never>(.authorized)

  nonisolated var authStatus: AuthorizationStatus {
    _authStatus.value
  }

  nonisolated var authStatusUpdates: AsyncStream<AuthorizationStatus> {
    _authStatus.removeDuplicates().values.eraseToStream()
  }

  nonisolated
  func initialize() {
    updateAuthStatus(
      ATTrackingManager.trackingAuthorizationStatus
    )

    logger.info("initialize success")
  }

  nonisolated func isAuthRequestNeeded() -> Bool {
    if #available(iOS 14.5, *) {
      return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    }
    return false
  }

  func requestAuthorization(
    delayFor interval: Double
  ) async -> AuthorizationStatus {
    logger.info("request authorization")

    if #available(iOS 14.5, *) {
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
        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
      }

      let attStatus = await ATTrackingManager.requestTrackingAuthorization()
      let status = AuthorizationStatus(attStatus)

      updateAuthStatus(attStatus)

      analytics.log(
        .event(
          eventName: .idfaResponse,
          parameters: [
            .status: status.description
          ]
        )
      )

      logger.info("authorization request success", dump: [
        "status": status
      ])

      return status
    }

    logger.info("request authorization not needed, iOS < 14.5")

    return .authorized
  }

  func sendTrackingData() async {
    logger.info("send tracking data")

    do {
      let amplitude = Amplitude.instance()
      let params = AdaptyProfileParameters.Builder()
        .with(appTrackingTransparencyStatus: authStatus.atAuthorizationStatus)
        .with(amplitudeDeviceId: amplitude.deviceId)
        .with(amplitudeUserId: amplitude.userId)
        .with(facebookAnonymousId: AppEvents.shared.anonymousID)
        .with(firebaseAppInstanceId: FirebaseAnalytics.Analytics.appInstanceID())
        .build()

      try await Adapty.updateProfile(params: params)

      logger.info("send tracking data success")
    } catch {
      logger.error("send tracking data failure", dump: [
        "error": error.localizedDescription
      ])
    }
  }

  nonisolated
  private func updateAuthStatus(
    _ status: ATTrackingManager.AuthorizationStatus
  ) {
    _authStatus.value = .init(status)

    let isAuthorized = status == .authorized
    let fbSettings = FacebookCore.Settings.shared
    fbSettings.isAdvertiserIDCollectionEnabled = isAuthorized
    fbSettings.isAdvertiserTrackingEnabled = isAuthorized
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
