import ComposableArchitecture
import DuckAnalyticsClient

private typealias NotificationsAccessAction = AnalyticsClient.NotificationsAccessAction

/// One screen view per appearance and one action per tap, both tagged with the
/// placement the host presented from.
@Reducer
struct NotificationsAccessRequestAnalytics {
  @Dependency(\.analytics) var analytics

  var body: some ReducerOf<NotificationsAccessRequest> {
    Reduce { state, action in
      let placement = state.placement?.rawValue

      switch action {
      case .onAppear:
        return .run { [analytics] _ in analytics.log(.notificationsAccessView) }

      case .laterButtonTapped:
        return log(NotificationsAccessAction.later, placement: placement)
      case .notifyButtonTapped:
        return log(NotificationsAccessAction.notify, placement: placement)
      }
    }
  }

  private func log(
    _ action: String,
    placement: String?
  ) -> Effect<NotificationsAccessRequest.Action> {
    .run { [analytics] _ in
      analytics.log(
        .notificationsAccessAction,
        parameters: [
          .action: action as any Sendable,
          .placement: placement
        ].compactMapValues { $0 }
      )
    }
  }
}

extension AnalyticsClient.EventName {
  static var notificationsAccessView: Self { "screen_notifications_view" }
  static var notificationsAccessAction: Self { "screen_notifications_action" }
}

extension AnalyticsClient {
  enum NotificationsAccessAction {
    static var later: String { "later" }
    static var notify: String { "notify" }
  }
}
