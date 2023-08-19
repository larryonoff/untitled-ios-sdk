import Dependencies

extension DependencyValues {
  public var analytics: AnalyticsClient {
    get { self[AnalyticsClient.self] }
    set { self[AnalyticsClient.self] = newValue }
  }
}

public struct AnalyticsClient {
  public var logEvent: @Sendable (EventName, [EventParameterName: Any]?) -> Void
  public var setUserProperty: @Sendable (Any?, UserPropertyName) -> Void

  public init(
    logEvent: @escaping @Sendable (EventName, [EventParameterName: Any]?) -> Void,
    setUserProperty: @escaping @Sendable (Any?, UserPropertyName) -> Void
  ) {
    self.logEvent = logEvent
    self.setUserProperty = setUserProperty
  }
}

extension AnalyticsClient {
  public func log(
    _ eventName: EventName,
    parameters: [EventParameterName: Any]? = nil
  ) {
    self.logEvent(eventName, parameters)
  }

  public func set(
    _ value: Any?,
    for name: UserPropertyName
  ) {
    self.setUserProperty(value, name)
  }
}
