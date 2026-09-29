import ComposableArchitecture
import DuckAnalyticsClient
import DuckComposableArchitecture
import DuckPurchases

@Reducer
public struct PostDeclineIntroOffer: Sendable {
  public enum Action {
    public enum Delegate {
      case declined
      case purchased
      case restored
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
    public var placement: Placement?
    public var product: Product

    public var isPurchasing: Bool = false

    public var isSelectedEligibleForTrial: Bool {
      product.isEligibleForIntroFreeTrial
    }

    @Presents
    public var destination: Destination.State?
  }

  @Reducer
  public enum Destination {
    case alert(AlertState<Alert>)

    public enum Alert: Equatable {
      case cancelIntroductoryOffer
    }
  }

  private enum CancelID {
    case purchase
  }

  @Dependency(\.analytics) var analytics
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
        state.destination = .alert(.cancelOffer)

        return .none
      case .purchaseTapped:
        return purchase(state: &state)
      case .restorePurchasesTapped:
        return restorePurchases(state: &state)
      case let .purchaseResponse(result):
        state.isPurchasing = false

        do {
          switch try result.get() {
          case .pending, .success:
            return .concatenate(
              analytics.logPurchase(
                .success,
                product: state.product,
                paywallID: state.paywallID,
                placement: state.placement
              ),
              .send(.delegate(.purchased))
            )
          case .userCancelled:
            return analytics.logPurchase(
              .cancelled,
              product: state.product,
              paywallID: state.paywallID,
              placement: state.placement
            )
          }
        } catch {
          state.destination = .alert(.failure(error))

          return analytics.logPurchase(
            .failure,
            product: state.product,
            paywallID: state.paywallID,
            placement: state.placement,
            error: error
          )
        }
      case let .restorePurchasesResponse(result):
        state.isPurchasing = false

        do {
          let restoreResult = try result.get()
          let logRestore: Effect<Action> = analytics.logRestore(
            RestoreAction(restoreResult),
            paywallID: state.paywallID,
            placement: state.placement
          )

          switch restoreResult {
          case .success:
            return .concatenate(logRestore, .send(.delegate(.restored)))
          case .userCancelled:
            return logRestore
          }
        } catch {
          state.destination = .alert(.failure(error))

          return analytics.logRestore(
            .failure,
            paywallID: state.paywallID,
            placement: state.placement,
            error: error
          )
        }
      case .destination(.presented(.alert(.cancelIntroductoryOffer))):
        return decline(state: &state)
      case .destination:
        return .none
      }
    }
  }

  // MARK: - Effects

  private func decline(
    state: inout State
  ) -> Effect<Action> {
    if state.destination != nil {
      state.destination = nil

      return .concatenate(
        .run { _ in try? await Task.sleep(nanoseconds: 1_000_000_00) },
        decline(state: &state)
      )
    }

    return .send(.delegate(.declined))
  }

  private func purchase(
    state: inout State
  ) -> Effect<Action> {
    // `purchase` and `restorePurchases` share a cancel ID, so a second request
    // arriving mid-flight would cancel the first rather than queue behind it.
    guard !state.isPurchasing else {
      return .none
    }

    state.isPurchasing = true

    return .merge(
      analytics.logPurchase(
        .attempt,
        product: state.product,
        paywallID: state.paywallID,
        placement: state.placement
      ),
      .run { [
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
    )
  }

  private func purchaseCancel(
    state: inout State
  ) -> Effect<Action> {
    guard state.isPurchasing else {
      return .none
    }

    state.isPurchasing = false
    return .cancel(id: CancelID.purchase)
  }

  private func restorePurchases(
    state: inout State
  ) -> Effect<Action> {
    guard !state.isPurchasing else {
      return .none
    }

    state.isPurchasing = true

    return .merge(
      analytics.logRestore(
        .attempt,
        paywallID: state.paywallID,
        placement: state.placement
      ),
      .run { send in
        await send(
          .restorePurchasesResponse(
            await Result {
              try await purchases.restorePurchases()
            }
          )
        )
      }
      .cancellable(id: CancelID.purchase, cancelInFlight: true)
    )
  }
}

extension PostDeclineIntroOffer.Destination.State: Equatable {}
