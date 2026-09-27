import DuckAnalyticsClient
import DuckCore

// The names BEAT ships, so the system-prompt funnel reads the same in every app.
extension AnalyticsClient.EventName {
  static let notificationsPromptView: Self = "popup_notifications_request_view"
  static let notificationsPromptAction: Self = "popup_notifications_request_action"
}

enum NotificationsPromptAction: String {
  case authorize
  case deny
  case fail
}

extension AnalyticsClient {
  func logPromptView(placement: Placement?) {
    log(
      .notificationsPromptView,
      parameters: [
        .placement: placement?.rawValue
      ].compactMapValues { $0 }
    )
  }

  func logPromptAction(_ action: NotificationsPromptAction, placement: Placement?) {
    log(
      .notificationsPromptAction,
      parameters: [
        .action: action.rawValue,
        .placement: placement?.rawValue
      ].compactMapValues { $0 }
    )
  }
}
