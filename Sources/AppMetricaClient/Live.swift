import DuckDependencies
import DuckLogging
import DuckUserIdentifierClient
import Foundation
import OSLog
import YandexMobileMetrica
import YandexMobileMetricaCrashes

extension AppMetricaClient {
  public static func live(
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    guard let apiKey = Bundle.main.appMetricaAPIKey else {
      assertionFailure("Cannot find valid AppMetrica settings")
      return Self.noop
    }

    let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey)!
    configuration.crashReporting = true
    configuration.sessionTimeout = 5 * 60
    configuration.userProfileID = userIdentifier().uuidString

    #if DEBUG
    configuration.logs = true
    #endif

    YMMYandexMetrica.activate(with: configuration)

    return Self(
      deviceID: {
        do {
          return try await YMMYandexMetrica
            .requestAppMetricaDeviceID(withCompletionQueue: nil)
        } catch {
          logger.error("deviceID failure", dump: [
            "error": error
          ])
          return nil
        }
      },
      reset: {
        YMMYandexMetrica.setUserProfileID(
          userIdentifier().uuidString
        )
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
  subsystem: "OnelightSDK.YandexAppMetrica",
  category: "YandexAppMetrica"
)
