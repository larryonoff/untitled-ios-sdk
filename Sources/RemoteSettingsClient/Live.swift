import Dependencies
import DuckLogging
import Foundation
import FirebaseRemoteConfig
import OSLog

extension RemoteSettingsClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = RemoteSettingsImpl()

    return Self(
      fetch: {
        try await impl.fetch($0)
      },
      registerDefaults: { defaults in
        let newDefaults = defaults
          .compactMapValues { $0 as? NSObject }
        RemoteConfig.remoteConfig()
          .setDefaults(newDefaults)
      },
      boolForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)

        return value.source == .static
          ? nil
          : value.boolValue
      },
      dataForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)

        return value.source == .static
          ? nil
          : value.dataValue
      },
      doubleForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)

        return value.source == .static
          ? nil
          : value.numberValue.doubleValue
      },
      integerForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)

        return value.source == .static
          ? nil
          : value.numberValue.intValue
      },
      stringForKey: { key in
        let value = RemoteConfig.remoteConfig()
          .configValue(forKey: key)

        return value.source == .static
          ? nil
          : value.stringValue
      },
      dictionaryRepresentation: {
        let remoteConfig = RemoteConfig.remoteConfig()

        let keys = remoteConfig
          .keys(withPrefix: nil)
          .map { ($0, remoteConfig[$0].stringValue ?? "nil") }
        return Dictionary(uniqueKeysWithValues: keys)
      }
    )
  }()
}

private final class RemoteSettingsImpl {
  private var fetchTask: Task<Void, Error>?

  init() {}

  func fetch(_ request: RemoteSettingsClient.FetchRequest) async throws {
    if let fetchTask {
      return try await fetchTask.value
    }

    let task = Task {
      defer { fetchTask = nil }

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

          let wasActivated = try await remoteConfig.activate()

          logger.info("activate response", dump: [
            "request": request,
            "status": status,
            "success": wasActivated
          ])
        }
      } catch {
        logger.error("fetch and activate", dump: [
          "request": request,
          "error": error
        ])

        throw error
      }
    }

    self.fetchTask = task

    return try await task.value
  }
}

private let logger = Logger(
  subsystem: ".SDK.remote-settings",
  category: "RemoteSettings"
)
