import ComposableArchitecture

extension PaywallReducer.State {
  @inlinable
  public var isRestoreDisabled: Bool {
    isFetchingPaywall || isPurchasing
  }

  public var isSelectedEligibleForTrial: Bool {
    isEligibleForIntroductoryOffer &&
    productSelected?.isEligibleForTrial == true
  }

  public var isSelectedEligibleForPromoOffer: Bool {
    promoOfferType != nil &&
    productSelected?.isEligibleForPromoOffer == true
  }
}

extension PaywallReducer {
  func presentPostDeclineIntroOfferIfNeeded(_ state: inout State) -> Bool {
    guard remoteSettings.isPaywallOnboardingIntroOfferEnabled else { return false }
    guard state.isEligibleForIntroductoryOffer else { return false }

    if let product = state.paywall?.introductoryOfferProduct {
      state.destination = .postDeclineIntroOffer(
        .init(
          paywallID: state.paywallID,
          product: product,
          isEligibleForIntroductoryOffer: state.isEligibleForIntroductoryOffer
        )
      )

      return true
    }

    return false
  }
}
