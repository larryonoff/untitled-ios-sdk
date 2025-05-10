import DuckCore

extension AutoPresentation {
  public struct FeatureCondition: Sendable {
    public var isEligibleForPresentation: @Sendable (
      _ event: AutoPresentation.Event?,
      _ placement: Placement?,
      _ userInfo: UserInfo?
    ) -> Bool

    public var increment: @Sendable () async -> Void
    public var logEvent: @Sendable (Event) async -> Void
    public var reset: @Sendable () async -> Void

    public init(
      isEligibleForPresentation: @escaping @Sendable (
        _ event: AutoPresentation.Event?,
        _ placement: Placement?,
        _ userInfo: AutoPresentation.UserInfo?
      ) -> Bool,
      increment: @escaping @Sendable () async -> Void,
      logEvent: @escaping @Sendable (AutoPresentation.Event) async -> Void,
      reset: @escaping @Sendable () async -> Void
    ) {
      self.isEligibleForPresentation = isEligibleForPresentation
      self.increment = increment
      self.logEvent = logEvent
      self.reset = reset
    }
  }
}
