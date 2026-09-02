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
      TextState(.CancelIntroductoryOffer.title)
    } actions: {
      ButtonState(role: .destructive, action: .cancelIntroductoryOffer) {
        TextState(.CancelIntroductoryOffer.Action.reject)
      }

      ButtonState(role: .cancel) {
        TextState(.CancelIntroductoryOffer.Action.cancel)
      }
    } message: {
      TextState(.CancelIntroductoryOffer.message)
    }
  }
}
