import ComposableArchitecture
import DuckAnalyticsClient
import DuckComposableArchitecture
import DuckPurchasesClient
import DuckRemoteSettingsClient
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

    case fetchPaywallResponse(Result<Paywall?, Error>)
    case purchaseResponse(Result<PurchaseResult, Error>, Product)
    case restorePurchasesResponse(Result<RestorePurchasesResult, Error>)

    case destination(PresentationAction<Destination.Action>)
    case products(IdentifiedActionOf<ProductItem>)
  }

  @ObservableState
  public struct State: Equatable {
    @Presents
    public var destination: Destination.State?

    public let paywallID: Paywall.ID
    public var paywall: Paywall?

    public var products: IdentifiedArrayOf<Product> = []
    public var productComparing: Product?
    public var productSelectedID: Product.ID?

    public var productSelected: Product? {
      productSelectedID.flatMap { productID in
        paywall?.products.first { $0.id == productID }
      }
    }

    public var placement: Placement?

    public var isEligibleForIntroductoryOffer: Bool = false
    public var isFetchingPaywall: Bool = false
    public var isHiddenPricesEnabled: Bool = true
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
  public struct ProductItem {
    public enum Action {
      case tapped
    }

    public typealias State = Product
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case alert(AlertState<Alert>)
    case freeTrial(PaywallFreeTrial)

    public enum Alert: Equatable {
      case rejectIntroductoryOffer
    }
  }

  private enum CancelID: Hashable {
    case purchase
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.purchases) var purchases
  @Dependency(\.remoteSettings) var remoteSettings

  public init() {}

  public var body: some ReducerOf<Self> {
    coreBody
      .ifLet(\.$destination, action: \.destination)
  }

  @ReducerBuilder<State, Action>
  private var coreBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .onAppear:
        state.isEligibleForIntroductoryOffer =
          purchases.purchases().isEligibleForIntroductoryOffer
        state.isHiddenPricesEnabled = remoteSettings.isPaywallProductHiddenPricesEnabled

        return .concatenate(
          fetchPaywall(state: &state),
          analytics.logView(state: state)
        )
      case .cancelPurchaseTapped:
        return purchaseCancel(state: &state)
      case .dismissTapped:
        if presentIntroductoryOfferIfNeeded(&state) {
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

          var products = (paywall?.products ?? [])

          if
            let filteredProductIDs = paywall?.filteredProductIDs,
            !filteredProductIDs.isEmpty
          {
            products = products.filter { !filteredProductIDs.contains($0.id) }
          }

          state.paywall = paywall
          state.products = IdentifiedArray(uncheckedUniqueElements: products)

          state.productComparing = paywall?.productComparing
          state.productSelectedID =
            paywall?.productSelected?.id ?? products.first?.id

          if let paywall = paywall {
            return .run { _ in
              try await purchases.logPaywall(paywall)
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
          case let .success:
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
        let isIntroOfferPresented = state.destination?.is(\.freeTrial) == true

        state.destination = nil

        if isIntroOfferPresented {
          return dismiss(state: &state)
        }

        return .none
      case .destination(.presented(.freeTrial(.delegate(.dismiss)))):
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
        .run { _ in try? await Task.sleep(nanoseconds: 1_000_000_00) },
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
      try? await Task.sleep(nanoseconds: 1_000_000_00)

      for try await response in purchases.paywallByID(paywallID) {
        await send(.fetchPaywallResponse(.success(response.paywall)))
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
