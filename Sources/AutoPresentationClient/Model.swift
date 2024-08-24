import DuckCore
@_exported import Tagged

public enum AutoPresentation {
  public enum EventTag: Sendable {}
  public typealias Event = Tagged<EventTag, String>

  public enum FeatureTag: Sendable {}
  public typealias Feature = Tagged<FeatureTag, String>

  public struct FeatureCondition: Sendable {
    public var canPresent: @Sendable (
      _ for: Placement?,
      _ userInfo: Any?
    ) -> Bool

    public var increment: @Sendable () -> Void
    public var logEvent: @Sendable (Event) -> Void
    public var reset: @Sendable () -> Void

    public init(
      canPresent: @escaping @Sendable (Placement?, Any?) -> Bool,
      increment: @escaping @Sendable () -> Void,
      logEvent: @escaping @Sendable (Event) -> Void,
      reset: @escaping @Sendable () -> Void
    ) {
      self.canPresent = canPresent
      self.increment = increment
      self.logEvent = logEvent
      self.reset = reset
    }
  }
}

extension AutoPresentation.Event {
  public static let saveOrShare: Self = "save_share"
}
