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

  public var log: (EventData) -> Effect<Never, Never>
  public var setUserProperty: (Any?, UserPropertyName) -> Effect<Never, Never>

  public init(
    log: @escaping (EventData) -> Effect<Never, Never>,
    setUserProperty: @escaping (Any?, UserPropertyName) -> Effect<Never, Never>
  ) {
    self.log = log
    self.setUserProperty = setUserProperty
  }
}

extension Analytics {
  public func log(
    _ eventName: EventName
  ) -> Effect<Never, Never> {
    self.log(.event(eventName: eventName))
  }

  public func set(
    _ value: Any?,
    for name: UserPropertyName
  ) -> Effect<Never, Never> {
    self.setUserProperty(value, name)
  }
}
