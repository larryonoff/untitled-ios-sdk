import ComposableArchitecture

extension AlertState<PaywallReducer.Destination.Action.Alert> {
  static var cancelIntroductoryOffer: Self {
    AlertState {
      TextState(L10n.CancelIntroductoryOffer.title)
    } actions: {
      ButtonState(role: .destructive, action: .rejectIntroductoryOffer) {
        TextState(L10n.CancelIntroductoryOffer.Action.reject)
      }

      ButtonState(role: .cancel) {
        TextState(L10n.CancelIntroductoryOffer.Action.cancel)
      }
    } message: {
      TextState(L10n.CancelIntroductoryOffer.message)
    }
  }
}
