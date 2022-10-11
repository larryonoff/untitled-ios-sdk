import Dependencies

extension DependencyValues {
  public var analytics: Analytics {
    get { self[Analytics.self] }
    set { self[Analytics.self] = newValue }
  }
}

public struct Analytics {
  public var log: (EventData) -> Void
  public var setUserProperty: (Any?, UserPropertyName) -> Void
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
