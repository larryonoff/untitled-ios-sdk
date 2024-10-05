import DuckAnalyticsClient
import DuckFoundation
import FirebaseAnalytics

extension AnalyticsClient {
  public static func firebase() -> Self {
    Self(
      logEvent: { eventName, parameters in
        FirebaseAnalytics.Analytics.log(
          eventName,
          parameters: parameters
        )
      },
      setUserProperty: { value, name in
        FirebaseAnalytics.Analytics.set(value, for: name)
      }
    )
  }
}

extension FirebaseAnalytics.Analytics {
  static func log(
    _ eventName: AnalyticsClient.EventName,
    parameters: [AnalyticsClient.EventParameterName: Any]?
  ) {
    let _parameters = parameters?
      .mapKeys(\.rawValue)
      .mapValues { value -> Any in
        if let value = value as? any CustomStringConvertible {
          return value.description
        }
        return value
      }

    logEvent(
      eventName.rawValue,
      parameters: _parameters
    )
  }

  static func set(
    _ value: Any?,
    for name: AnalyticsClient.UserPropertyName
  ) {
    setUserProperty(
      value.flatMap { String(describing: $0) },
      forName: name.rawValue
    )
  }
}
