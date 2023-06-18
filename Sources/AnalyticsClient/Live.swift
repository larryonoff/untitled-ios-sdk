import Amplitude
import FacebookCore
import FirebaseAnalytics
import FoundationSupport

extension Analytics {
  public static let live: Self = {
    Analytics(
      log: { data in
        Amplitude.instance().log(data)

        #if os(iOS)
        AppEvents.shared.log(data)
        #endif

        FirebaseAnalytics.Analytics.log(data)
      },
      setUserProperty: { value, name in
        Amplitude.instance().set(value, for: name)

        FirebaseAnalytics.Analytics.set(value, for: name)
      }
    )
  }()
}

extension Amplitude {
  func log(_ data: Analytics.EventData) {
    let properties = data.parameters?.mapKeys(\.rawValue)

    logEvent(
      data.eventName.rawValue,
      withEventProperties: properties
    )
  }

  func set(
    _ value: Any?,
    for name: Analytics.UserPropertyName
  ) {
    let identity = AMPIdentify()

    if let value = value {
      identity.set(
        name.rawValue,
        value: String(describing: value) as NSString
      )
    } else {
      identity.unset(name.rawValue)
    }

    identify(identity)
  }
}

#if os(iOS)
extension AppEvents {
  func log(_ data: Analytics.EventData) {
    let parameters = data.parameters?
      .mapKeys { AppEvents.ParameterName($0.rawValue) }
      .mapValues { value -> Any in
        if let value = value as? CustomStringConvertible {
          return value.description
        }
        return value
      }

    logEvent(
      AppEvents.Name(rawValue: data.eventName.rawValue),
      parameters: parameters ?? [:]
    )
  }
}
#endif

extension FirebaseAnalytics.Analytics {
  static func log(_ data: Analytics.EventData) {
    let parameters = data.parameters?
      .mapKeys(\.rawValue)
      .mapValues { value -> Any in
        if let value = value as? CustomStringConvertible {
          return value.description
        }
        return value
      }

    logEvent(
      data.eventName.rawValue,
      parameters: parameters
    )
  }

  static func set(
    _ value: Any?,
    for name: Analytics.UserPropertyName
  ) {
    setUserProperty(
      value.flatMap { String(describing: $0) },
      forName: name.rawValue
    )
  }
}
