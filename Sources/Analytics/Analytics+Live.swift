import Amplitude
import ComposableArchitecture
import FacebookCore
import FirebaseAnalytics
import FoundationExt

extension Analytics {
  public static let live: Self = {
    Analytics(
      log: { data in
        Amplitude.instance().log(data)

        AppEvents.shared.log(data)

        FirebaseAnalytics.Analytics.log(data)
      },
      setUserProperty: { value, name in
        let identity = AMPIdentify()

        if let value = value {
          identity.set(
            name.rawValue,
            value: String(describing: value) as NSString
          )
        } else {
          identity.unset(name.rawValue)
        }

        let amplitude = Amplitude.instance()
        amplitude.identify(identity)
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
}

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
}
