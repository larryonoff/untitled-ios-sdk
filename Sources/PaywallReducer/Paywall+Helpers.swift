import ComposableArchitecture

extension PaywallReducer.State {
  @inlinable
  public var isRestoreDisabled: Bool {
    isFetchingPaywall || isPurchasing
  }

  public var isSelectedEligibleForTrial: Bool {
    productSelected?.isEligibleForTrial == true &&
    isEligibleForIntroductoryOffer
  }
}

extension PaywallReducer {
  func presentIntroductoryOfferIfNeeded(_ state: inout State) -> Bool {
    guard remoteSettings.isSubsOnboardingIntroOfferEnabled else { return false }
    guard state.isEligibleForIntroductoryOffer else { return false }

    if let product = state.paywall?.introductoryOfferProduct {
      state.destination = .freeTrial(
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
