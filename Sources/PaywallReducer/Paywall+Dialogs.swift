import ComposableArchitecture
import Foundation

extension AlertState<PaywallReducer.Destination.Alert> {
  /// Reports a failure the user can retry.
  ///
  /// `dismissAction` is what the second button does once the user gives up.
  /// Passing `nil` leaves it inert, which is what an onboarding paywall wants:
  /// the alert has to be dismissable, but dismissing it must not become a way
  /// out of the funnel.
  static func failure(
    _ error: any Swift.Error,
    retryAction: Action,
    dismissAction: Action? = nil
  ) -> Self {
    AlertState {
      TextState(error.localizedDescription)
    } actions: {
      ButtonState(action: retryAction) {
        TextState(L10n.Failure.Action.retry)
      }

      ButtonState(role: .cancel, action: .send(dismissAction)) {
        TextState(L10n.Failure.Action.ok)
      }
    }
  }
}
