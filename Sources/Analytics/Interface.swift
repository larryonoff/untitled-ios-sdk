import ComposableArchitecture
import Tagged

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
