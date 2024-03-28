import AppMetricaCore
import AppMetricaCrashes
import DuckDependencies
import DuckLogging
import DuckUserIdentifierClient
import Foundation
import OSLog

extension AppMetricaClient {
  public static func live(
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    guard let apiKey = Bundle.main.appMetricaAPIKey else {
      assertionFailure("Cannot find valid AppMetrica settings")
      return Self.noop
    }

    let configuration = AppMetricaConfiguration(apiKey: apiKey)!
    configuration.sessionTimeout = 5 * 60
    configuration.sessionsAutoTracking = true
    configuration.userProfileID = userIdentifier().uuidString

//    #if DEBUG
//    configuration.areLogsEnabled = true
//    #endif

    AppMetrica.activate(with: configuration)

    return Self(
      deviceID: {
        AppMetrica.deviceID
      },
      reset: {
        AppMetrica.userProfileID = userIdentifier().uuidString
      }
    )
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
