import ComposableArchitecture
import DuckAnalyticsClient

extension RateUs {
  var analyticsBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { _ in analytics.log(.rateUsView) }
      case .contactUsTapped:
        return .run { [placement = state.placement] _ in
          analytics.log(
            .rateUsDoNotLoveAction,
            parameters: [
              .action: AnalyticsClient.RateUsAction.contact as Any,
              .placement: placement?.rawValue
            ].compactMapValues { $0 }
          )
        }
      case .dismissTapped:
        return .run { [placement = state.placement] send in
          analytics.log(
            .rateUsDoNotLoveAction,
            parameters: [
              .action: AnalyticsClient.RateUsAction.dismiss as Any,
              .placement: placement?.rawValue
            ].compactMapValues { $0 }
          )
        }
      case .doNotLoveTapped:
        return .run { [placement = state.placement] _ in
          analytics.log(
            .rateUsAction,
            parameters: [
              .action: AnalyticsClient.RateUsAction.doNotLove as Any,
              .placement: placement?.rawValue
            ].compactMapValues { $0 }
          )
        }
      case .loveTapped:
        return .run { [placement = state.placement] _ in
          analytics.log(
            .rateUsAction,
            parameters: [
              .action: AnalyticsClient.RateUsAction.love as Any,
              .placement: placement?.rawValue
            ].compactMapValues { $0 }
          )
        }
      default:
        return .none
      }
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

