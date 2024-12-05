import ComposableArchitecture
import DuckAnalyticsClient
import DuckComposableArchitecture
import DuckPaywallDependencies
import DuckPurchasesClient
import DuckPurchasesComposable
import IdentifiedCollections

@Reducer
public struct PaywallReducer {
  public enum Action {
    public enum Delegate {
      case dismiss
    }

    case delegate(Delegate)

    case onAppear

    case cancelPurchaseTapped
    case dismissTapped
    case restorePurchasesTapped

    case purchase

    case setSelectedProductID(Product.ID?)

    case fetchPaywallResponse(Result<Paywall?, any Error>)
    case purchaseResponse(Result<PurchaseResult, any Error>, Product)
    case restorePurchasesResponse(Result<RestorePurchasesResult, any Error>)

    case destination(PresentationAction<Destination.Action>)
    case products(IdentifiedActionOf<ProductItem>)
  }

  @ObservableState
  public struct State: Equatable {
    @Presents
    public var destination: Destination.State?

    public var isFetchingPaywall: Bool = false
    public var isPurchasing: Bool = false

    public var paywallType: Paywall.PaywallType
    public var paywallID: Paywall.ID
    public var paywall: Paywall?

    public var products: IdentifiedArrayOf<Product> = []
    public var productComparing: Product?
    public var productSelectedID: Product.ID?

    public var placement: Placement?

    // MARK: - Calculated Props

    public var isEligibleForIntroOffer: Bool {
      purchases.isEligibleForIntroductoryOffer
    }

    public var productSelected: Product? {
      productSelectedID.flatMap { productID in
        paywall?.products.first { $0.id == productID }
      }
    }

    public var eligibleOffer: Product.EligibleSubscriptionOffer? {
      paywall?.eligibleOffers.first
    }

    // MARK: - Shared State

    @SharedReader(.isPaywallProductHiddenPricesEnabled) public var isHiddenPricesEnabled
    @SharedReader(.isPaywallOnboardingIntroOfferEnabled) public var isOnboardingIntroOfferEnabled
    @SharedReader(.purchases) public var purchases
    @SharedReader(.purchasesOffer) public var purchasesOffer

    // MARK: Init

    public init(
      paywallID: Paywall.ID,
      paywallType: Paywall.PaywallType,
      placement: Placement?
    ) {
      self.paywallType = paywallType
      self.paywallID = paywallID
      self.placement = placement
    }

    public init(
      paywallType: Paywall.PaywallType,
      placement: Placement?
    ) {
      @Dependency(\.paywallID) var paywallID

      self.paywallType = paywallType
      self.paywallID = paywallID(paywallType)
      self.placement = placement
    }

    public init(placement: Placement?) {
      @Dependency(\.paywallID) var paywallID
      @Dependency(\.paywallType) var paywallType

      let paywallType_ = paywallType(placement)

      self.paywallType = paywallType_
      self.paywallID = paywallID(paywallType_)
      self.placement = placement
    }
  }

  @Reducer
  public struct ProductItem {
    public enum Action {
      case tapped
    }

    public typealias State = Product
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case alert(AlertState<Alert>)
    case postDeclineIntroOffer(PostDeclineIntroOffer)

    public enum Alert: Equatable {
      case rejectIntroductoryOffer
    }
  }

  private enum CancelID: Hashable {
    case purchase
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.purchases) var purchases

  public init() {}

  public var body: some ReducerOf<Self> {
    CombineReducers {
      PurchasesOffersLogic()

      coreBody
        .ifLet(\.$destination, action: \.destination)
    }
  }

  @ReducerBuilder<State, Action>
  private var coreBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none

      case .onAppear:
        return .concatenate(
          fetchPaywall(state: &state),
          analytics.logView(state: state)
        )

      case .cancelPurchaseTapped:
        return purchaseCancel(state: &state)
      case .dismissTapped:
        if presentPostDeclineIntroOfferIfNeeded(&state) {
          return .none
        }

        return dismiss(state: &state)
      case .restorePurchasesTapped:
        return restorePurchases(state: &state)

      case let .setSelectedProductID(productID):
        return selectProduct(withID: productID, state: &state)

      case .purchase:
        return purchase(state: &state)

      case let .fetchPaywallResponse(result):
        state.isFetchingPaywall = false

        do {
          let paywall = try result.get()
          let paywallChanged = paywall?.id != state.paywall?.id

          state.update(paywall)

          if let paywall, paywallChanged {
            return .run { _ in
              try await purchases.log(paywall)
            }
          }
        } catch {
          state.paywall = nil
          state.productSelectedID = nil
          state.destination = .alert(.failure(error))
        }

        return .none
      case let .purchaseResponse(result, product):
        state.isPurchasing = false

        do {
          switch try result.get() {
          case .pending, .success:
            return .concatenate(
              analytics.logPurchase(product, result: result, state: state),
              .send(.delegate(.dismiss))
            )
          case .userCancelled:
            return .none
          }
        } catch {
          state.destination = .alert(.failure(error))

          return analytics.logPurchase(product, result: result, state: state)
        }
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

      case .destination(.dismiss):
        let isPostDeclinePresented = state.destination?.is(\.postDeclineIntroOffer) == true

        state.destination = nil

        if isPostDeclinePresented {
          return dismiss(state: &state)
        }

        return .none
      case .destination(.presented(.postDeclineIntroOffer(.delegate(.dismiss)))):
        return dismiss(state: &state)
      case .destination:
        return .none

      case let .products(.element(id: productID, action: .tapped)):
        return selectProduct(withID: productID, state: &state)
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
        .run { _ in try? await Task.sleep(for: .nanoseconds(1_000_000_00)) },
        dismiss(state: &state)
      )
    }

    return .send(.delegate(.dismiss))
  }

  private func fetchPaywall(
    state: inout State
  ) -> Effect<Action> {
    state.isFetchingPaywall = true

    return .run(priority: .high) { [paywallID = state.paywallID] send in
      // HACK
      // sometimes product cannot be selected or purchased
      try? await Task.sleep(for: .nanoseconds(1_000_000_00))

      for try await paywall in purchases.paywall(by: paywallID) {
        await send(.fetchPaywallResponse(.success(paywall)))
      }
    } catch: { error, send in
      await send(.fetchPaywallResponse(.failure(error)))
    }
  }

  private func purchase(
    _ product: Product,
    state: inout State
  ) -> Effect<Action> {
    state.isPurchasing = true

    return .merge(
      analytics.logPurchase(product, state: state),
      .run { [paywallID = state.paywallID] send in
        let result = await Result {
          try await purchases.purchase(
            .request(product: product, paywallID: paywallID)
          )
        }

        await send(.purchaseResponse(result, product))
      }
      .cancellable(id: CancelID.purchase, cancelInFlight: true)
    )
  }

  private func purchase(
    state: inout State
  ) -> Effect<Action> {
    guard let product = state.productSelected else {
      return .none
    }
    return purchase(product, state: &state)
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
      let result = await Result {
        try await purchases.restorePurhases()
      }

      await send(.restorePurchasesResponse(result))
    }
    .cancellable(id: CancelID.purchase, cancelInFlight: true)
  }

  private func selectProduct(
    withID productID: Product.ID?,
    state: inout State
  ) -> Effect<Action> {
    let productChanged = productID != state.productSelected?.id

    state.productSelectedID = productID

    if
      let product = state.productSelected,
      !productChanged
    {
      return purchase(product, state: &state)
    }

    return .none
  }
}
