import Adapty
import AppsFlyerLib
import AppTrackingTransparency
import Combine
import ComposableArchitecture
import Foundation
import LoggingSupport
import os.log
import UIKit
import UserIdentifier

extension AppsFlyerClient {
  public static func live(
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    let impl = AppsFlyerClientImpl(
      userIdentifier: userIdentifier
    )

    return AppsFlyerClient(
      initialize: {
        impl.initialize($0)
      },
      appContinueUserActivity: { userActivity, restorationHandler in
        impl.app(
          continue: userActivity,
          restorationHandler: restorationHandler
        )
      },
      appOpenURL: { url, options in
        impl.app(
          open: url,
          options: options
        )
      },
      applicationID: {
        AppsFlyerLib.shared().getAppsFlyerUID()
      },
      logEvent: {
        AppsFlyerLib.shared().logEvent($0, withValues: nil)
      },
      reset: {
        impl.reset()
      }
    )
  }
}

final class AppsFlyerClientImpl {
  private let lock = NSRecursiveLock()
  private var appsFlyerDelegate: _AppsFlyerDelegate?
  private var appsFlyerDelegateTask: Task<Void, Never>?
  private var appDidBecomeActiveTask: Task<Void, Never>?

  private let userIdentifier: UserIdentifierGenerator

  init(
    userIdentifier: UserIdentifierGenerator
  ) {
    self.userIdentifier = userIdentifier
  }

  func initialize(
    _ configuration: AppsFlyerClient.Configuration
  ) {
    lock.lock(); lock.unlock()

    logger.info("initialize", dump: [
      "configuration": configuration
    ])

    guard self.appsFlyerDelegate == nil else {
      logger.error("AppsFlyer already configured")
      return
    }

    let bundle = Bundle.main
    guard let apiKey = bundle.appsFlyerAPIKey else {
      assertionFailure("Cannot find a valid AppsFlyer settings")

      logger.error("initialize", dump: [
        "error": "Cannot find a valid AppsFlyer settings"
      ])

      return
    }

    if configuration.isAdaptyEnabled, Adapty.delegate == nil {
      assertionFailure("Adapty must be configured first")

      logger.info("initialize", dump: [
        "error": "Adapty not configured"
      ])
    }

    appsFlyerDelegate = _AppsFlyerDelegate()

    let tracker = AppsFlyerLib.shared()
    tracker.appsFlyerDevKey = apiKey
    tracker.delegate = appsFlyerDelegate

    if let appleID = bundle.appleID {
      tracker.appleAppID = appleID
    }

    tracker.customerUserID = userIdentifier().uuidString

    if
      ATTrackingManager.trackingAuthorizationStatus == .notDetermined,
      let timeout = configuration.userTracking?.authorizationWaitTimeoutInterval
    {
      tracker.waitForATTUserAuthorization(timeoutInterval: timeout)

      logger.info("initialize: waitForATTUserAuthorization", dump: [
        "timeoutInterval": timeout
      ])
    }

    appsFlyerDelegateTask = Task.detached(priority: .high) { [weak self] in
      guard
        let appsFlyerDelegate = self?.appsFlyerDelegate
      else {
        return
      }

      for await event in appsFlyerDelegate.stream {
        switch event {
        case let .onConversionDataSuccess(conversionInfo):
          guard configuration.isAdaptyEnabled else {
            continue
          }

          let tracker = AppsFlyerLib.shared()

          do {
            try await Adapty.updateAttribution(
              conversionInfo,
              source: .appsflyer,
              networkUserId: tracker.getAppsFlyerUID()
            )

            logger.info("Adapty updateAttribution success")
          } catch {
            logger.error("Adapty updateAttribution failure", dump: [
              "error": error.localizedDescription
            ])
          }
        case .onConversionDataFail:
          break
        case .onAppOpenAttribution:
          break
        case .onAppOpenAttributionFailure:
          break
        }
      }
    }

    appDidBecomeActiveTask = Task.detached { [weak self] in
      if await UIApplication.shared.applicationState == .active {
        logger.info("AppsFlyer.start", dump: [
          "reason": "application already active"
        ])
        try? await self?.start()
      }

      // the first run may cause `minTimeBetweenSessions` error

      await withTaskGroup(of: Void.self) { group in
        let didBecomeActive = await NotificationCenter.default
          .notifications(named: UIApplication.didBecomeActiveNotification)

        for await _ in didBecomeActive {
          group.addTask { [weak self] in
            logger.info("AppsFlyer.start", dump: [
              "reason": "application did become active"
            ])

            try? await self?.start()
          }
        }
      }
    }

    logger.info("initialize success")
  }

  func start() async throws {
    do {
      try await AppsFlyerLib.shared().start()

      logger.info("AppsFlyer.start success")
    } catch {
      logger.error("AppsFlyer.start failure", dump: [
        "error": error.localizedDescription
      ])
      throw error
    }
  }

  func reset() {
    let tracker = AppsFlyerLib.shared()
    tracker.customerUserID = userIdentifier().uuidString
  }

  func app(
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) {
    let tracker = AppsFlyerLib.shared()
    tracker.continue(
      userActivity,
      restorationHandler: { objects in
        let restorableObjects = objects?.compactMap { $0 as? UIUserActivityRestoring }
        restorationHandler(restorableObjects)
      }
    )
  }

  func app(
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) {
    let tracker = AppsFlyerLib.shared()
    tracker.handleOpen(url, options: options)
  }
}

// MARK: - AppsFlyerLibDelegate

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
enum AppsFlyerDelegateEvent {
  case onConversionDataSuccess([AnyHashable: Any])
  case onConversionDataFail(Error)
  case onAppOpenAttribution([AnyHashable: Any])
  case onAppOpenAttributionFailure(Error)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class _AppsFlyerDelegate: NSObject, AppsFlyerLibDelegate {
  private let subject =
    PassthroughSubject<AppsFlyerDelegateEvent, Never>()

  var stream: AsyncStream<AppsFlyerDelegateEvent> {
    AsyncStream(subject.values)
  }

  override init() {
    super.init()
  }

  // AppsFlyerLibDelegate

  func onConversionDataSuccess(
    _ conversionInfo: [AnyHashable: Any]
  ) {
    logger.info(#function, dump: [
      "conversionInfo": conversionInfo
    ])

    subject.send(
      .onConversionDataSuccess(conversionInfo)
    )
  }

  func onConversionDataFail(
    _ error: Error
  ) {
    logger.error(#function, dump: [
      "error": error.localizedDescription
    ])

    subject.send(
      .onConversionDataFail(error)
    )
  }

  func onAppOpenAttribution(
    _ attributionData: [AnyHashable: Any]
  ) {
    logger.info(#function, dump: [
      "attributionData": attributionData
    ])

    subject.send(
      .onAppOpenAttribution(attributionData)
    )
  }

  func onAppOpenAttributionFailure(
    _ error: Error
  ) {
    logger.error(#function, dump: [
      "error": error.localizedDescription
    ])

    subject.send(
      .onAppOpenAttributionFailure(error)
    )
  }
}

private let logger = Logger(
  subsystem: ".SDK.AppsFlyer",
  category: "AppsFlyer"
)
