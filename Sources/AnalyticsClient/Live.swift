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

        logger.info("logEvent", dump: [
          "eventName": eventName,
          "parameters": parameters as Any
        ])
      },
      setUserProperty: { value, propertyName in
        for client in clients {
          client.setUserProperty(value, propertyName)
        }

        logger.info("setUserProperty", dump: [
          "propertyName": propertyName,
          "value": value as Any
        ])
      }
    )
  }
}

private let logger = Logger(
  subsystem: "DuckSDK.AnalyticsClient",
  category: "Analytics"
)
