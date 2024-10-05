import ComposableArchitecture
import DuckPurchasesClient

@Reducer
public struct PaywallFreeTrial {
  public enum Action {
    public enum Delegate {
      case dismiss
    }

    case delegate(Delegate)

    case cancelPurchaseTapped
    case dismissTapped
    case purchaseTapped
    case restorePurchasesTapped

    case purchaseResponse(Result<PurchaseResult, any Error>)
    case restorePurchasesResponse(Result<RestorePurchasesResult, any Error>)

    case destination(PresentationAction<Destination.Action>)
  }

  @ObservableState
  public struct State: Equatable {
    public var paywallID: Paywall.ID
    public var product: Product

    public var isEligibleForIntroductoryOffer: Bool
    public var isPurchasing: Bool = false

    public var isSelectedEligibleForTrial: Bool {
      product.isEligibleForTrial && isEligibleForIntroductoryOffer
    }

    @Presents
    public var destination: Destination.State?
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case alert(AlertState<Alert>)

    public enum Alert: Equatable {
      case cancelIntroductoryOffer
    }
  }

  private enum CancelID {
    case purchase
  }

  @Dependency(\.purchases) var purchases

  public var body: some ReducerOf<Self> {
    coreBody
      .ifLet(\.$destination, action: \.destination)
  }

  private var coreBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .cancelPurchaseTapped:
        return purchaseCancel(state: &state)
      case .dismissTapped:
        state.destination = .alert(.cancelIntroductoryOffer)

        return .none
      case .purchaseTapped:
        return purchase(state: &state)
      case .restorePurchasesTapped:
        return restorePurchases(state: &state)
      case let .purchaseResponse(result):
        state.isPurchasing = false

        do {
          switch try result.get() {
          case .success:
            return .send(.delegate(.dismiss))
          case .userCancelled:
            return .none
          }
        } catch {
          state.destination = .alert(.failure(error))
        }

        return .none
      case let .restorePurchasesResponse(result):
        state.isPurchasing = false

        do {
          switch try result.get() {
          case .success:
            return .send(.delegate(.dismiss))
          case .userCancelled:
            return .none
          }
        } catch {
          state.destination = .alert(.failure(error))
        }

        return .none
      case .destination(.presented(.alert(.cancelIntroductoryOffer))):
        return dismiss(state: &state)
      case .destination:
        return .none
      }
    }
  }

  // MARK: - Effects

  private func dismiss(
    state: inout State
  ) -> Effect<Action> {
    if state.destination != nil {
      state.destination = nil

      return .concatenate(
        .run { _ in try? await Task.sleep(nanoseconds: 1_000_000_00) },
        dismiss(state: &state)
      )
    }

    return .send(.delegate(.dismiss))
  }

  private func purchase(
    state: inout State
  ) -> Effect<Action> {
    state.isPurchasing = true

    return .run { [
      paywallID = state.paywallID,
      product = state.product
    ] send in
      let result = await Result {
        try await purchases.purchase(
          .request(product: product, paywallID: paywallID)
        )
      }
      await send(.purchaseResponse(result))
    }
    .cancellable(id: CancelID.purchase, cancelInFlight: true)
  }

  private func purchaseCancel(
    state: inout State
  ) -> Effect<Action> {
    state.isPurchasing = false
    return .cancel(id: CancelID.purchase)
  }

  private func restorePurchases(
    state: inout State
  ) -> Effect<Action> {
    state.isPurchasing = true

    return .run { send in
      await send(
        .restorePurchasesResponse(
          await Result {
            try await purchases.restorePurhases()
          }
        )
      )
    }
    .cancellable(id: CancelID.purchase, cancelInFlight: true)
  }
}
