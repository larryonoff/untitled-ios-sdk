import ComposableArchitecture
import DuckAnalyticsClient

private typealias RateUsAction = AnalyticsClient.RateUsAction

/// One screen view per appearance and one action per tap, both tagged with the
/// placement the host presented from.
@Reducer
struct RateUsAnalytics {
  @Dependency(\.analytics) var analytics

  var body: some ReducerOf<RateUs> {
    Reduce { state, action in
      let placement = state.placement?.rawValue

      switch action {
      case .onAppear:
        return .run { [analytics] _ in analytics.log(.rateUsView) }

      case .cancelTapped:
        return log(.rateUsDoNotLoveAction, RateUsAction.dismiss, placement: placement)
      case .contactSupportTapped:
        return log(.rateUsDoNotLoveAction, RateUsAction.contact, placement: placement)
      case .doNotLoveTapped:
        return log(.rateUsAction, RateUsAction.doNotLove, placement: placement)
      case .loveTapped:
        return log(.rateUsAction, RateUsAction.love, placement: placement)
      }
    }
  }

  private func log(
    _ event: AnalyticsClient.EventName,
    _ action: String,
    placement: String?
  ) -> Effect<RateUs.Action> {
    .run { [analytics] _ in
      analytics.log(
        event,
        parameters: [
          .action: action as any Sendable,
          .placement: placement
        ].compactMapValues { $0 }
      )
    }
  }
}

extension AnalyticsClient.EventName {
  static var rateUsView: Self { "screen_rate_us_view" }
  static var rateUsAction: Self { "screen_rate_us_action" }
  static var rateUsDoNotLoveView: Self { "screen_rate_us_dont_love_view" }
  static var rateUsDoNotLoveAction: Self { "screen_rate_us_dont_love_action" }
}

extension AnalyticsClient {
  enum RateUsAction {
    static var dismiss: String { "close" }
    static var contact: String { "contact_us" }
    static var doNotLove: String { "dont_love" }
    static var love: String { "love" }
  }
}
