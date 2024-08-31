import DuckCore
@_exported import Tagged

public enum AutoPresentation {
  public enum EventTag: Sendable {}
  public typealias Event = Tagged<EventTag, String>

  public enum FeatureTag: Sendable {}
  public typealias Feature = Tagged<FeatureTag, String>

  public enum UserInfoKeyTag: Sendable {}
  public typealias UserInfoKey = Tagged<FeatureTag, String>

  public typealias UserInfo = [UserInfoKey: Any]

  public struct FeatureCondition: Sendable {
    public var isEligibleForPresentation: @Sendable (
      _ for: Placement?,
      _ userInfo: UserInfo?
    ) -> Bool

    public var increment: @Sendable () async -> Void
    public var logEvent: @Sendable (Event) async -> Void
    public var reset: @Sendable () async -> Void

    public init(
      isEligibleForPresentation: @escaping @Sendable (
        Placement?,
        UserInfo?
      ) -> Bool,
      increment: @escaping @Sendable () async -> Void,
      logEvent: @escaping @Sendable (Event) async -> Void,
      reset: @escaping @Sendable () async -> Void
    ) {
      self.isEligibleForPresentation = isEligibleForPresentation
      self.increment = increment
      self.logEvent = logEvent
      self.reset = reset
    }
  }
}
