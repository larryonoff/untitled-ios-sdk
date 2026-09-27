import ComposableArchitecture
import DuckPurchasesCore
import DuckPurchasesOffers

/// Records the paywall facts that offers are derived from.
struct PurchasesOffersLogic: Reducer {
  @Dependency(\.date.now) var now

  var body: some ReducerOf<PaywallReducer> {
    Reduce { state, action in
      switch action {
      case let .fetchPaywallResponse(.success(paywall)):
        // A paywall whose config carries a duration, not an end date, starts
        // its offer's countdown the first time it's shown.
        guard
          let paywall,
          paywall.offerEndDate == nil,
          let duration = paywall.offerDuration
        else {
          return .none
        }

        let kind = state.target.kind
        state.$offerHistory.withLock {
          $0.startCountdown(for: kind, duration: duration, at: now)
        }
        return .none

      case .onDisappear:
        // `onDisappear`, not `dismissTapped`: a swipe-down counts too.
        let kind = state.target.kind
        state.$offerHistory.withLock { $0.recordDismissal(of: kind, at: now) }
        return .none

      default:
        return .none
      }
    }
  }
}
