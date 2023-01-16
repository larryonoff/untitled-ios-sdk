import Tagged

extension Analytics {
  public typealias EventName = Tagged<(Analytics, evenName: ()), String>
  public typealias ParameterName = Tagged<(Analytics, parameterName: ()), String>
  public typealias UserPropertyName = Tagged<(Analytics, userProperty: ()), String>

  public struct EventData {
    public var eventName: EventName
    public var parameters: [ParameterName: Any]?
  }
}

extension Analytics.EventData: @unchecked Sendable {}

extension Analytics.EventData {
  public static func event(
    eventName: Analytics.EventName,
    parameters: [Analytics.ParameterName: Any]? = nil
  ) -> Self {
    .init(
      eventName: eventName,
      parameters: parameters
    )
  }
}
