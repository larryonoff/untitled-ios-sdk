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
/// Has no auto-presentation or remote-push coupling — the host owns *when* the
/// sheet appears and
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

    /// Does what Notify does — prompt, or route a decided user to Settings —
    /// for a host that shows no soft ask, so no screen or tap is reported.
    case systemPromptRequested
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    /// True from an accepted Notify, Later or direct request until the
    /// presentation closes; further taps are ignored meanwhile.
    public internal(set) var isRequesting = false

    var hasAppeared = false

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
    // First, so it sees the state before `core` marks the request busy.
    Analytics()
    core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.hasAppeared = true
        return .none

      case .laterButtonTapped:
        guard !state.isRequesting else { return .none }
        state.isRequesting = true
        return .run { [dismiss] _ in await dismiss() }

      case .notifyButtonTapped, .systemPromptRequested:
        guard !state.isRequesting else { return .none }
        state.isRequesting = true
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
          let status = await notificationsAuthorization.status()
          guard !Task.isCancelled else { return }

          guard status.allowsPrompt else {
            // Dismissed first: Settings replaces the app, and coming back to a
            // sheet asking to enable what was just enabled reads as a failure.
            await dismiss()
            await openNotificationSettings()

            return
          }

          // The sheet stays up behind the system prompt and closes once it is
          // answered, so the request is never left with the prompt on screen
          // and nothing behind it.
          do {
            _ = try await notificationsAuthorization.requestAuthorization(request)
          } catch {
            // The authorization client owns sanitized failure analytics. Both
            // denial and failure finish this ask; neither implies a grant.
          }

          // Closing the presentation cancels this effect, but the system can
          // still answer afterwards; that answer must not dismiss its successor.
          guard !Task.isCancelled else { return }
          await dismiss()
        }
      }
    }
  }
}
