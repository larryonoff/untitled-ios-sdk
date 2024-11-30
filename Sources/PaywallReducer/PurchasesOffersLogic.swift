import ComposableArchitecture
import DuckPurchasesOffersClient

struct PurchasesOffersLogic: Reducer {
  @Dependency(\.purchasesOffers) var purchasesOffers

  var body: some ReducerOf<PaywallReducer> {
    Reduce { state, action in
      switch action {
      case .dismissTapped:
        purchasesOffers.logPaywallEvent(
          paywall: state.paywall,
          paywallType: state.paywallType,
          event: .dismiss
        )

        return .none
      case let .fetchPaywallResponse(result):
        guard let paywall = try? result.get() else {
          return .none
        }

        purchasesOffers.logPaywallEvent(
          paywall: paywall,
          paywallType: state.paywallType,
          event: .present
        )

        return .none
      default:
        return .none
      }
    }
  }
}
