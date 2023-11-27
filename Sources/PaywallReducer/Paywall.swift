import ComposableArchitecture
import DuckAnalyticsClient
import DuckComposableArchitecture
import DuckPurchasesClient
import IdentifiedCollections

@Reducer
public struct PaywallReducer {
  public enum Action {
    public enum Delegate {
      case dismiss
    }

    public enum ProductAction {
      case tapped
    }

    case onAppear
    case delegate(Delegate)

    case dismissTapped
    case purchaseCancelled
    case restorePurchasesTapped

    case purchase

    case fetchPaywallResponse(Result<Paywall?, Error>)

    case purchaseResponse(Result<PurchaseResult, Error>)
    case restorePurchasesResponse(Result<RestorePurchasesResult, Error>)

    case destination(PresentationAction<Destination.Action>)
    case products(IdentifiedAction<Product.ID, ProductAction>)
  }

  public struct State: Equatable {
    @PresentationState
    public var destination: Destination.State?

    public let paywallID: Paywall.ID
    public var paywall: Paywall?

    public var products: IdentifiedArrayOf<Product> = []
    public var productComparing: Product?
    public var productSelected: Product?

    public var placement: Placement?

    public var isEligibleForIntroductoryOffer: Bool = false
    public var isFetchingPaywall: Bool = false
    public var isPurchasing: Bool = false

    public init(
      paywallID: Paywall.ID,
      placement: Placement?
    ) {
      self.paywallID = paywallID
      self.placement = placement
    }
  }

  @Reducer
  public struct Destination {
    public enum Action {
      public enum Alert: Equatable {}

      case alert(Alert)
    }

    public enum State: Equatable {
      case alert(AlertState<Action.Alert>)
    }

    public var body: some ReducerOf<Self> {
      EmptyReducer()
    }
  }

  private enum CancelID: Hashable {
    case purchase
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.purchases) var purchases

  public init() {}

  public var body: some ReducerOf<Self> {
    coreReducer
      .ifLet(\.$destination, action: \.destination) {
        Destination()
      }
  }

  @ReducerBuilder<State, Action>
  private var coreReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isEligibleForIntroductoryOffer =
          purchases.purchases().isEligibleForIntroductoryOffer
        state.isFetchingPaywall = true

        return .concatenate(
          .run { [paywallID = state.paywallID] send in
            // HACK
            // sometimes product cannot be selected or purchased
            try? await Task.sleep(nanoseconds: 1_000_000_00)

            for try await response in purchases.paywalByID(paywallID) {
              await send(
                .fetchPaywallResponse(
                  .success(response.paywall)
                )
              )
            }
          } catch: { error, send in
            await send(.fetchPaywallResponse(.failure(error)))
          },
          logPaywallOpened(state: state)
        )
      case .delegate:
        return .none
      case .dismissTapped:
        return .merge(
          logPaywallDismissed(state: state),
          .send(.delegate(.dismiss))
        )
      case .purchaseCancelled:
        state.isPurchasing = false

        return .cancel(id: CancelID.purchase)
      case .restorePurchasesTapped:
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
      case .purchase:
        guard let product = state.productSelected else {
          return .none
        }
        return purchase(product, state: &state)
      case let .fetchPaywallResponse(result):
        state.isFetchingPaywall = false

        do {
          let paywall = try result.get()

          var products = (paywall?.products ?? [])

          if let paywall, paywall.filterPayUpFrontProduct {
            products = products
              .filter { $0.id != paywall.payUpFrontProductID }
          }

          state.paywall = paywall
          state.products = IdentifiedArray(uncheckedUniqueElements: products)

          state.productComparing = paywall?.productComparing
          state.productSelected =
            paywall?.productSelected ?? products.first

          if let paywall = paywall {
            return .run { _ in
              try await purchases.logPaywall(paywall)
            }
          }
        } catch {
          state.paywall = nil
          state.productSelected = nil
          state.destination = .alert(.failure(error))
        }

        return .none
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
      case let .products(.element(id: productID, action: .tapped)):
        let productChanged = productID != state.productSelected?.id

        state.productSelected = state.paywall?
          .products
          .first { $0.id == productID }

        if
          let product = state.productSelected,
          !productChanged
        {
          return purchase(product, state: &state)
        }

        return .none
      case .destination:
        return .none
      }
    }
  }

  // MARK: - Effects

  private func purchase(
    _ product: Product,
    state: inout State
  ) -> Effect<Action> {
    state.isPurchasing = true

    return .run { [paywallID = state.paywallID] send in
      await send(
        .purchaseResponse(
          await Result {
            try await purchases
              .purchase(.request(product: product, paywallID: paywallID))
          }
        )
      )
    }
    .cancellable(id: CancelID.purchase, cancelInFlight: true)
  }

  // MARK: - Analytics

  private func logPaywallOpened(
    state: State
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params[.contentID] = state.paywallID
    params[.placement] = state.placement

    return .run { [params] _ in
      analytics.log(
        "paywall_opened",
        parameters: params
      )
    }
  }

  private func logPaywallDismissed(
    state: State
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params[.contentID] = state.paywallID
    params[.placement] = state.placement

    return .run { [params] _ in
      analytics.log(
        "paywall_dismissed",
        parameters: params
      )
    }
  }
}
