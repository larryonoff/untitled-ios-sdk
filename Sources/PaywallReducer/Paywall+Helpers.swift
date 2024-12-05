import ComposableArchitecture
import DuckPurchases

extension PaywallReducer.State {
  mutating
  func update(_ paywall: Paywall?) {
    var products = (paywall?.products ?? [])

    if
      let filteredProductIDs = paywall?.filteredProductIDs,
      !filteredProductIDs.isEmpty
    {
      products = products.filter { !filteredProductIDs.contains($0.id) }
    }

    self.paywall = paywall
    self.products = IdentifiedArray(uncheckedUniqueElements: products)

    self.productComparing = paywall?.productComparing
    self.productSelectedID =
      paywall?.productSelected?.id ?? products.first?.id
  }
}

extension PaywallReducer.State {
  @inlinable
  public var isRestoreDisabled: Bool {
    isFetchingPaywall || isPurchasing
  }

  public var isSelectedEligibleForTrial: Bool {
    isEligibleForIntroOffer &&
    productSelected?.isEligibleForTrial == true
  }
}

extension PaywallReducer {
  func presentPostDeclineIntroOfferIfNeeded(_ state: inout State) -> Bool {
    guard state.isOnboardingIntroOfferEnabled else { return false }
    guard state.isEligibleForIntroOffer else { return false }

    if let product = state.paywall?.introductoryOfferProduct {
      state.destination = .postDeclineIntroOffer(
        .init(
          paywallID: state.paywallID,
          product: product,
          isEligibleForIntroductoryOffer: state.isEligibleForIntroOffer
        )
      )

      return true
    }

    return false
  }
}
