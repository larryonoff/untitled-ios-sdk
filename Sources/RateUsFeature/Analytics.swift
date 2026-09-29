import ComposableArchitecture
import DuckAnalyticsClient
import DuckUserSessionClient
import Foundation

private typealias RateUsAction = AnalyticsClient.RateUsAction

/// One screen view per appearance and one action per tap, both tagged with the
/// placement the host presented from and how far into its life the app was,
/// so an ask that comes too early shows up in the data.
@Reducer
struct RateUsAnalytics {
  @Dependency(\.analytics) var analytics
  @Dependency(\.calendar) var calendar
  @Dependency(\.date) var date
  @Dependency(\.userSession) var userSession

  var body: some ReducerOf<RateUs> {
    Reduce { state, action in
      let placement = state.placement?.rawValue

      switch action {
      case .onAppear:
        return log(.rateUsView, placement: placement)

      case .backTapped:
        return log(.rateUsDoNotLoveAction, RateUsAction.back, placement: placement)
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
    _ action: String? = nil,
    placement: String?
  ) -> Effect<RateUs.Action> {
    let metrics = userSession.metrics()
    let daysSinceInstall = calendar
      .dateComponents([.day], from: metrics.installationDate, to: date.now)
      .day

    let parameters: [AnalyticsClient.EventParameterName: (any Sendable)?] = [
      .action: action,
      .daysSinceInstall: daysSinceInstall,
      .placement: placement,
      .sessionNumber: Int(metrics.totalSessionCount)
    ]

    return .run { [analytics] _ in
      analytics.log(event, parameters: parameters.compactMapValues { $0 })
    }
  }
}

extension AnalyticsClient.EventName {
  static let rateUsView: Self = "screen_rate_us_view"
  static let rateUsAction: Self = "screen_rate_us_action"
  static let rateUsDoNotLoveView: Self = "screen_rate_us_dont_love_view"
  static let rateUsDoNotLoveAction: Self = "screen_rate_us_dont_love_action"
}

extension AnalyticsClient.EventParameterName {
  static let daysSinceInstall: Self = "days_since_install"
  static let sessionNumber: Self = "session_number"
}

extension AnalyticsClient {
  enum RateUsAction {
    static let back = "back"
    static let dismiss = "close"
    static let contact = "contact_us"
    static let doNotLove = "dont_love"
    static let love = "love"
  }
}
