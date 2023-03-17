import Foundation
import FirebaseRemoteConfig
import LoggingSupport
import os.log

extension RemoteSettingsClient {
  public static let live: Self = {
    return Self(
      fetch: { request in
        do {
          logger.info("fetch request", dump: [
            "request": request
          ])

          let remoteConfig = RemoteConfig.remoteConfig()

          let status = try await remoteConfig
            .fetch(withExpirationDuration: request.expirationDuration)

          logger.info("fetch response", dump: [
            "request": request,
            "status": status
          ])

          if request.activate {
            logger.info("activate request")

            let activateSuccess = try await remoteConfig.activate()

            logger.info("activate response", dump: [
              "request": request,
              "status": status,
              "success": activateSuccess
            ])
          }
        } catch {
          logger.error("fetch and activate", dump: [
            "request": request,
            "error": error.localizedDescription
          ])

          throw error
        }
      },
      registerDefaults: { defaults in
        let newDefaults = defaults
          .compactMapValues { $0 as? NSObject }
        RemoteConfig.remoteConfig()
          .setDefaults(newDefaults)
      },
      boolForKey: { key in
        return RemoteConfig.remoteConfig()
          .configValue(forKey: key)
          .boolValue
      },
      dataForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)
          .dataValue
        return value.isEmpty ? nil : value
      },
      doubleForKey: { key in
        return RemoteConfig.remoteConfig()
          .configValue(forKey: key)
          .numberValue
          .doubleValue
      },
      integerForKey: { key in
        return RemoteConfig.remoteConfig()
          .configValue(forKey: key)
          .numberValue
          .intValue
      },
      stringForKey: { key in
        return RemoteConfig.remoteConfig()
          .configValue(forKey: key)
          .stringValue
      },
      dictionaryRepresentation: {
        let remoteConfig = RemoteConfig.remoteConfig()

        let keys = remoteConfig
          .keys(withPrefix: nil)
          .map { ($0, remoteConfig[$0].stringValue ?? "") }
        return Dictionary(uniqueKeysWithValues: keys)
      }
    )
  }()
}

private let logger = Logger(
  subsystem: ".SDK.remote-settings",
  category: "RemoteSettings"
)
