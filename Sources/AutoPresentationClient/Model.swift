import DuckCore
@_exported import Tagged

public enum AutoPresentation {
  public enum EventTag: Sendable {}
  public typealias Event = Tagged<EventTag, String>

  public enum FeatureTag: Sendable {}
  public typealias Feature = Tagged<FeatureTag, String>

  public enum UserInfoKeyTag: Sendable {}
  public typealias UserInfoKey = Tagged<UserInfoKeyTag, String>

  public typealias UserInfo = [UserInfoKey: any Sendable]

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
        _ for: Placement?,
        _ userInfo: UserInfo?
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

extension AutoPresentation {
  /// An occasion to present something automatically.
  public struct Request: Sendable {
    /// Where the presentation would be raised from, if the caller knows.
    public var placement: Placement?

    /// Additional information a feature's condition may need.
    public var userInfo: UserInfo?

    /// Whether this request may present even though something else already
    /// presented this session.
    ///
    /// The once-per-session guard stops a launch from stacking automatic
    /// presentations at the user. A request raised by the user's own action is
    /// the moment its feature is meant to appear, so losing it to an unrelated
    /// feature that presented earlier is a bug, not pacing. Reserve it for such
    /// triggers: the feature's condition still decides, and presenting still
    /// takes the session's slot.
    public var isForced: Bool

    public init(
      placement: Placement? = nil,
      userInfo: UserInfo? = nil,
      isForced: Bool = false
    ) {
      self.placement = placement
      self.userInfo = userInfo
      self.isForced = isForced
    }
  }
}

extension AutoPresentation {
  /// A presentation the client decided for a request.
  public struct Presentation: Sendable {
    public var feature: Feature
    public var request: Request

    public init(feature: Feature, request: Request) {
      self.feature = feature
      self.request = request
    }
  }
}

extension AutoPresentation.FeatureCondition {
  /// This condition, eligible only at `placements`.
  ///
  /// For a condition that accepts any placement, so that a forced request raised
  /// for another feature cannot present this one.
  public func limited(to placements: Set<Placement>) -> Self {
    var condition = self
    let isEligible = isEligibleForPresentation
    condition.isEligibleForPresentation = { placement, userInfo in
      guard let placement, placements.contains(placement) else { return false }
      return isEligible(placement, userInfo)
    }
    return condition
  }
}
