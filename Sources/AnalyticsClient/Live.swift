import DuckLogging
import OSLog

extension AnalyticsClient {
  public static func live(
    clients: [AnalyticsClient]
  ) -> Self {
    Self(
      logEvent: { eventName, parameters in
        for client in clients {
          client.logEvent(eventName, parameters)
        }

        logger.info(
          """
          analytics.log-event | \
          event_name: \(eventName.rawValue, privacy: .public)
          parameters: \(String(describing: parameters))
          """
        )
      },
      setUserProperty: { value, propertyName in
        for client in clients {
          client.setUserProperty(value, propertyName)
        }

        logger.info(
          """
          analytics.set-user-property | \
          property_name: \(propertyName.rawValue, privacy: .public)
          value: \(String(describing: value))
          """
        )
      }
    )
  }
}

private let logger = Logger(
  subsystem: "DuckSDK.AnalyticsClient",
  category: "Analytics"
)
