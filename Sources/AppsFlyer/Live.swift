import Adapty
import AppsFlyerLib
import AppTrackingTransparency
import ComposableArchitecture
import Foundation
import LoggingSupport
import os.log
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
        await impl.initialize($0)
      }
    )
  }
}

private final actor AppsFlyerClientImpl {
  private var appsFlyerDelegate: _AppsFlyerDelegate?

  private let userIdentifier: UserIdentifierGenerator

  init(
    userIdentifier: UserIdentifierGenerator
  ) {
    self.userIdentifier = userIdentifier
  }

  func initialize(
    _ configuration: AppsFlyerClient.Configuration
  ) async {
    guard self.appsFlyerDelegate == nil else {
      return
    }

    let bundle = Bundle.main
    guard let apiKey = bundle.appsFlyerAPIKey else {
      assertionFailure()
      return
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
      #available(iOS 14.5, *),
      ATTrackingManager.trackingAuthorizationStatus == .notDetermined,
      let timeout = configuration.userTracking?.authorizationWaitTimeoutInterval
    {
      tracker.waitForATTUserAuthorization(timeoutInterval: timeout)
    }

    _ = Task.detached(priority: .high) { [weak self] in
      guard
        let self = self,
        let appsFlyerDelegate = await self.appsFlyerDelegate
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

          try? await Adapty.updateAttribution(
            conversionInfo,
            source: .appsflyer,
            networkUserId: tracker.getAppsFlyerUID()
          )
        case .onConversionDataFail:
          break
        case .onAppOpenAttribution:
          break
        case .onAppOpenAttributionFailure:
          break
        }
      }
    }
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
  let pipe = AsyncStream<AppsFlyerDelegateEvent>.streamWithContinuation()

  var stream: AsyncStream<AppsFlyerDelegateEvent> {
    AsyncStream(pipe.stream)
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

    pipe.continuation.yield(
      .onConversionDataSuccess(conversionInfo)
    )
  }

  func onConversionDataFail(
    _ error: Error
  ) {
    logger.error(#function, dump: [
      "error": error.localizedDescription
    ])

    pipe.continuation.yield(
      .onConversionDataFail(error)
    )
  }

  func onAppOpenAttribution(
    _ attributionData: [AnyHashable: Any]
  ) {
    logger.info(#function, dump: [
      "attributionData": attributionData
    ])

    pipe.continuation.yield(
      .onAppOpenAttribution(attributionData)
    )
  }

  func onAppOpenAttributionFailure(
    _ error: Error
  ) {
    logger.error(#function, dump: [
      "error": error.localizedDescription
    ])

    pipe.continuation.yield(
      .onAppOpenAttributionFailure(error)
    )
  }
}

private let logger = Logger(
  subsystem: ".SDK.AppsFlyer",
  category: "AppsFlyer"
)
