import ComposableArchitecture
import Tagged

public struct Analytics {
  public typealias EventName = Tagged<(Analytics, evenName: ()), String>
  public typealias ParameterName = Tagged<(Analytics, parameterName: ()), String>
  public typealias UserPropertyName = Tagged<(Analytics, userProperty: ()), String>

  public struct EventData {
    public let eventName: EventName
    public let parameters: [ParameterName: Any]?

    public static func event(
      eventName: EventName,
      parameters: [ParameterName: Any]? = nil
    ) -> Self {
      .init(
        eventName: eventName,
        parameters: parameters
      )
    }
  }

  public var log: (EventData) -> Void
  public var setUserProperty: (Any?, UserPropertyName) -> Void

  public init(
    log: @escaping (EventData) -> Void,
    setUserProperty: @escaping (Any?, UserPropertyName) -> Void
  ) {
    self.log = log
    self.setUserProperty = setUserProperty
  }
}

extension Analytics {
  public func log(
    _ eventName: EventName
  ) {
    self.log(.event(eventName: eventName))
  }

  public func set(
    _ value: Any?,
    for name: UserPropertyName
  ) {
    self.setUserProperty(value, name)
  }
}
