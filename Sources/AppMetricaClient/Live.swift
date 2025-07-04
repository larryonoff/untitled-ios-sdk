import AppMetricaCore
import AppMetricaCrashes
import Dependencies
import DuckLogging
import DuckUserIdentifierClient
import Foundation
import OSLog

extension AppMetricaClient: DependencyKey {
  public static let liveValue: Self = {
    @Dependency(\.userIdentifier) var userIdentifier

    guard
      let apiKey = Bundle.main.appMetricaAPIKey,
      let config = AppMetricaConfiguration(apiKey: apiKey)
    else {
      logger.warning("Cannot find valid AppMetrica settings")
      return Self.noop
    }

    config.sessionTimeout = 5 * 60
    config.sessionsAutoTracking = true
    config.userProfileID = userIdentifier().uuidString

//    #if DEBUG
//    configuration.areLogsEnabled = true
//    #endif

    AppMetrica.activate(with: config)

    return Self(
      deviceID: {
        AppMetrica.deviceID
      },
      profileID: {
        AppMetrica.userProfileID
      },
      reportError: {
        AppMetricaCrashes.crashes().report(nserror: $0)
      },
      reportExternalAttribution: { attribution, attributionSource in
        AppMetrica.reportExternalAttribution(
          attribution,
          from: attributionSource._attributionSource
        )
      },
      reset: { [userIdentifier] in
        AppMetrica.userProfileID = userIdentifier().uuidString
      }
    )
  }()
}

extension AppMetricaClient.AttributionSource {
  var _attributionSource: AppMetricaCore.AttributionSource {
    switch self {
    case .appsFlyer: .appsflyer
    }
  }
}

extension Bundle {
  var appMetricaAPIKey: String? {
    infoDictionary?["XAppMetricaAPIKey"] as? String
  }
}

private let logger = Logger(
  subsystem: ".SDK.AppMetricaClient",
  category: "AppMetrica"
)
