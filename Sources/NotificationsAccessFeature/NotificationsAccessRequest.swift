import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
import DuckNotificationsAuthorizationClient

/// Pre-permission soft ask shown before the system notification prompt.
///
/// The system prompt is one-shot: a user who was never going to opt in spends
/// it, and the only way back is a trip through Settings. Asking in app copy
/// first keeps that prompt for people who say yes.
///
/// Mirrors BEAT's `UserNotificationsAccessRequest` without its auto-presentation
/// and remote-push coupling — the host owns *when* the sheet appears and
/// presents it with ``SwiftUI/View/notificationsAccessRequest(_:title:message:)``.
///
/// The grant itself is not reported back: the system status is the single
/// source of truth, and a host that observes it also catches a flip made in
/// Settings while the app was backgrounded.
@Reducer
public struct NotificationsAccessRequest {
  public enum Action {
    case onAppear

    case laterButtonTapped
    case notifyButtonTapped
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    /// What `NOTIFY ME` asks for. Its placement also tags this sheet's
    /// analytics; the reducer never branches on it.
    public var request: NotificationsAuthorization.Request

    public init(request: NotificationsAuthorization.Request = .prompt()) {
      self.request = request
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.notificationsAuthorization) var notificationsAuthorization
  @Dependency(\.openNotificationSettings) var openNotificationSettings

  public init() {}

  public var body: some ReducerOf<Self> {
    CombineReducers {
      core

      NotificationsAccessRequestAnalytics()
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .laterButtonTapped:
        return .run { [dismiss] _ in await dismiss() }

      case .notifyButtonTapped:
        return .run { [
          dismiss,
          notificationsAuthorization,
          openNotificationSettings,
          request = state.request
        ] _ in
          // A decided user gets no system prompt — re-asking silently replays
          // the recorded answer and reads as a broken button, so the button
          // routes them to Settings instead. A provisional user still has the
          // prompt: asking upgrades quiet delivery to full.
          guard await notificationsAuthorization.status().allowsPrompt else {
            // Dismissed first: Settings replaces the app, and coming back to a
            // sheet asking to enable what was just enabled reads as a failure.
            await dismiss()
            await openNotificationSettings()

            return
          }

          // The sheet stays up behind the system prompt and closes once it is
          // answered, so the request is never left with the prompt on screen
          // and nothing behind it.
          _ = try? await notificationsAuthorization.requestAuthorization(request)

          await dismiss()
        }
      }
    }
  }
}
