import DuckAnalyticsClient
import DuckFoundation
import AppMetricaCore

extension AnalyticsClient {
  public static func appMetrica(
    allowedEvents: [EventName]?
  ) -> Self {
    Self(
      logEvent: { eventName, parameters in
        if let allowedEvents, !allowedEvents.contains(eventName) {
          return
        }

        AppMetrica.log(
          eventName,
          parameters: parameters
        )
      },
      setUserProperty: { value, name in
        AppMetrica.set(value, for: name)
      }
    )
  }
}

extension AppMetrica {
  static func log(
    _ eventName: AnalyticsClient.EventName,
    parameters: [AnalyticsClient.EventParameterName: Any]?
  ) {
    let _parameters = parameters?
      .mapKeys(\.rawValue)
      .mapValues(String.init(describing:))

    reportEvent(
      name: eventName.rawValue,
      parameters: _parameters
    )
  }

  static func set(
    _ value: Any?,
    for name: AnalyticsClient.UserPropertyName
  ) {
    var update: UserProfileUpdate?

    if let _value = value as? Int {
      update = ProfileAttribute
        .customNumber(name.rawValue)
        .withValue(Double(_value))
    } else if let _value = value as? Double {
      update = ProfileAttribute
        .customCounter(name.rawValue)
        .withDelta(_value)
    } else if let _value = value as? Bool {
      update = ProfileAttribute
        .customBool(name.rawValue)
        .withValue(_value)
    }  else if let _value = value as? String {
      update = ProfileAttribute
        .customString(name.rawValue)
        .withValue(_value)
    }

    if let update {
      let profile = MutableUserProfile()
      profile.apply(update)

      reportUserProfile(profile)
    }
  }
}
