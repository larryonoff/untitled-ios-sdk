import DuckAnalyticsClient
import DuckFoundation
import YandexMobileMetrica

extension AnalyticsClient {
  public static func appMetrica(
    allowedEvents: [EventName]?
  ) -> Self {
    Self(
      logEvent: { eventName, parameters in
        if let allowedEvents, !allowedEvents.contains(eventName) {
          return
        }

        YMMYandexMetrica.log(
          eventName,
          parameters: parameters
        )
      },
      setUserProperty: { value, name in
        YMMYandexMetrica.set(value, for: name)
      }
    )
  }
}

extension YMMYandexMetrica {
  static func log(
    _ eventName: AnalyticsClient.EventName,
    parameters: [AnalyticsClient.EventParameterName: Any]?
  ) {
    let _parameters = parameters?
      .mapKeys(\.rawValue)
      .mapValues { value -> Any in
        if let value = value as? CustomStringConvertible {
          return value.description
        }
        return value
      }

    reportEvent(
      eventName.rawValue,
      parameters: _parameters
    )
  }

  static func set(
    _ value: Any?,
    for name: AnalyticsClient.UserPropertyName
  ) {
    var profileUpdate: YMMUserProfileUpdate?

    if let _value = value as? Int {
      profileUpdate = YMMProfileAttribute
        .customNumber(name.rawValue)
        .withValue(Double(_value))
    } else if let _value = value as? Double {
      profileUpdate = YMMProfileAttribute
        .customCounter(name.rawValue)
        .withDelta(_value)
    } else if let _value = value as? Bool {
      profileUpdate = YMMProfileAttribute
        .customBool(name.rawValue)
        .withValue(_value)
    }  else if let _value = value as? String {
      profileUpdate = YMMProfileAttribute
        .customString(name.rawValue)
        .withValue(_value)
    }

    if let profileUpdate {
      let profile = YMMMutableUserProfile()
      profile.apply(from: [
        profileUpdate
      ])

      report(profile)
    }
  }
}
