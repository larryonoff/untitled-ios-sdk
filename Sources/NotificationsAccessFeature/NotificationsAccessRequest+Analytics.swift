import ComposableArchitecture
import DuckAnalyticsClient
import DuckNotificationsAuthorizationClient

private typealias NotificationsAccessAction = AnalyticsClient.NotificationsAccessAction

/// One screen view per presentation and one action per accepted tap, tagged with the
/// placement the host presented from.
extension NotificationsAccessRequest {
  @Reducer
  struct Analytics {
    @Dependency(\.analytics) var analytics

    var body: some ReducerOf<NotificationsAccessRequest> {
      Reduce { state, action in
        let placement = state.request.placement?.rawValue

        switch action {
        case .onAppear:
          guard !state.hasAppeared else { return .none }
          return .run { [analytics] _ in
            analytics.log(
              .notificationsAccessView,
              parameters: [.placement: placement].compactMapValues { $0 }
            )
          }

        case .laterButtonTapped:
          guard !state.isRequesting else { return .none }
          return log(NotificationsAccessAction.later, placement: placement)
        case .notifyButtonTapped:
          guard !state.isRequesting else { return .none }
          return log(NotificationsAccessAction.notify, placement: placement)

        case .systemPromptRequested:
          return .none
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
}

private extension AnalyticsClient.EventName {
  static let notificationsAccessView: Self = "screen_notifications_view"
  static let notificationsAccessAction: Self = "screen_notifications_action"
}

private extension AnalyticsClient {
  enum NotificationsAccessAction {
    static let later: String = "later"
    static let notify: String = "notify"
  }
}
