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
          .map { ($0, remoteConfig[$0].stringValue) }
        return Dictionary(uniqueKeysWithValues: keys)
      }
    )
  }()
}

private actor RemoteSettingsImpl {
  private var fetchTask: Task<Void, any Error>?

  init() {}

  func fetch(_ request: RemoteSettingsClient.FetchRequest) async throws {
    if let fetchTask {
      return try await fetchTask.value
    }

    let task = Task {
      defer { fetchTask = nil }

      do {
        logger.info(
          """
          remote-settings.fetch | \
          is_activated: \(request.activate, privacy: .public) \
          duration: \(request.expirationDuration, privacy: .public)
          """
        )

        let remoteConfig = RemoteConfig.remoteConfig()

        let status = try await remoteConfig
          .fetch(withExpirationDuration: request.expirationDuration)

        logger.info(
          """
          remote-settings.fetch received | \
          is_activated: \(request.activate, privacy: .public) \
          duration: \(request.expirationDuration, privacy: .public) \
          status: \(status.rawValue, privacy: .public)
          """
        )

        if request.activate {
          logger.info("remote-settings.activate")

          let wasActivated = try await remoteConfig.activate()

          logger.info(
            """
            remote-settings.activate success | \
            is_activated: \(wasActivated, privacy: .public) \
            status: \(status.rawValue, privacy: .public)
            """
          )
        }
      } catch {
        logger.error(
          """
          remote-settings.fetch failed | \
          is_activated: \(request.activate, privacy: .public) \
          duration: \(request.expirationDuration, privacy: .public)
          error: \(error, privacy: .public)
          """
        )

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
