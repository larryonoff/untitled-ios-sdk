import ComposableArchitecture

extension PostDeclineIntroOffer.State {
  @inlinable
  public var isRestoreDisabled: Bool {
    isPurchasing
  }
}

extension AlertState<PostDeclineIntroOffer.Destination.Alert> {
  static var cancelOffer: Self {
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
