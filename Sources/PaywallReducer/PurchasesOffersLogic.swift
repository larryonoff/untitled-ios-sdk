import ComposableArchitecture
import DuckPurchasesCore
import DuckPurchasesOffers

/// Records the paywall facts that offers are derived from.
struct PurchasesOffersLogic: Reducer {
  @Dependency(\.date) var date

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
          $0.startCountdown(for: kind, duration: duration, at: date.now)
        }
        return .none

      case .onAppear:
        // Recorded when the paywall's effects are torn down, which every way
        // it goes away does: the close button, a swipe-down, a parent clearing
        // it. Not on `onDisappear`: by then the parent has usually cleared the
        // paywall's state, and the action no longer reaches this reducer.
        //
        // A repeated `onAppear` starts another wait; the history keeps the
        // first dismissal only, so the extra one records nothing new.
        let kind = state.target.kind
        return .run { [offerHistory = state.$offerHistory, date] _ in
          try? await Task.never()
          offerHistory.withLock { $0.recordDismissal(of: kind, at: date.now) }
        }

      default:
        return .none
      }
    }
  }
}
