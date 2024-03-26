import ComposableArchitecture

extension PaywallFreeTrial.State {
  @inlinable
  public var isRestoreDisabled: Bool {
    isPurchasing
  }
}

extension AlertState<PaywallFreeTrial.Destination.Alert> {
  static var cancelIntroductoryOffer: Self {
    AlertState {
      TextState(L10n.CancelIntroductoryOffer.title)
    } actions: {
      ButtonState(role: .destructive, action: .cancelIntroductoryOffer) {
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
