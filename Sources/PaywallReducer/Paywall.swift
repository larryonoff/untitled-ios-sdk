import Analytics
import ComposableArchitecture
import ComposableArchitectureExt
import IdentifiedCollections
import PurchasesClient

public struct PaywallReducer: ReducerProtocol {
  public enum Action: Equatable {
    public enum ProductAction: Equatable {
      case tapped
    }

    case onAppear
    case dismiss

    case fetchPaywallResponse(TaskResult<Paywall?>)

    case product(id: Product.ID, action: ProductAction)

    case purchase
    case purchaseCancelled
    case purchaseResponse(TaskResult<PurchaseResult>)

    case restorePurchases
    case restorePurchasesResponse(TaskResult<RestorePurchasesResult>)

    case alertDismissed
  }

  public struct State: Equatable {
    public var alert: AlertState<Action>?

    public let paywallID: Paywall.ID
    public var paywall: Paywall?

    public var products: IdentifiedArrayOf<Product> = []
    public var productComparing: Product?
    public var productSelected: Product?

    public var placement: Placement?

    public var dismiss: Bool = false

    public var isPurchasing: Bool = false
    public var isFetchingPaywall: Bool = false

    public init(
      paywallID: Paywall.ID,
      placement: Placement?
    ) {
      self.paywallID = paywallID
      self.placement = placement
    }
  }

  private enum PurchaseID {}

  @Dependency(\.analytics) var analytics
  @Dependency(\.purchases) var purchases

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isFetchingPaywall = true

        return .concatenate(
          .task { [paywallID = state.paywallID] in
            .fetchPaywallResponse(
              await TaskResult {
                try await purchases.paywalByID(paywallID)
              }
            )
          },
          logPaywallOpened(state: state)
        )
      case .dismiss:
        return logPaywallDismissed(state: state)
      case let .fetchPaywallResponse(.success(paywall)):
        state.isFetchingPaywall = false

        state.paywall = paywall

        let products = paywall?.products ?? []
        state.products = IdentifiedArray(uncheckedUniqueElements: products)

        state.productComparing = paywall?.productComparing
        state.productSelected =
          paywall?.productSelected ?? paywall?.products.first

        if let paywall = paywall {
          return .fireAndForget {
            try await purchases.logPaywall(paywall)
          }
        }

        return .none
      case let .fetchPaywallResponse(.failure(error)):
        state.isFetchingPaywall = false
        state.paywall = nil
        state.productSelected = nil
        state.alert = .failure(error)

        return .none
      case let .product(productID, .tapped):
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
      case .purchase:
        guard let product = state.productSelected else {
          return .none
        }
        return purchase(product, state: &state)
      case .purchaseCancelled:
        state.isPurchasing = false

        return .cancel(id: PurchaseID.self)
      case let .purchaseResponse(result):
        state.isPurchasing = false

        do {
          _ = try result.value
        } catch {
          state.alert = .failure(error)
        }

        return .none
      case .restorePurchases:
        state.isPurchasing = true

        return .task {
          .restorePurchasesResponse(
            await TaskResult {
              try await purchases.restorePurhases()
            }
          )
        }
        .cancellable(
          id: PurchaseID.self,
          cancelInFlight: true
        )
      case let .restorePurchasesResponse(result):
        state.isPurchasing = false

        do {
          _ = try result.value
        } catch {
          state.alert = .failure(error)
        }

        return .none
      case .alertDismissed:
        state.alert = nil
        return .none
      }
    }
  }

  // MARK: - Effects

  private func purchase(
    _ product: Product,
    state: inout State
  ) -> Effect<Action, Never> {
    state.isPurchasing = true

    return .task { [paywallID = state.paywallID] in
        .purchaseResponse(
          await TaskResult {
            try await purchases
              .purchase(.request(product: product, paywallID: paywallID))
          }
        )
    }
    .cancellable(
      id: PurchaseID.self,
      cancelInFlight: true
    )
  }

  // MARK: - Analytics

  private func logPaywallOpened(
    state: State
  ) -> EffectTask<Action> {
    var params: [Analytics.ParameterName: Any] = [:]
    params[.contentID] = state.paywallID
    params[.placement] = state.placement

    return .fireAndForget {
      analytics.log(
        .event(
          eventName: "paywall_opened",
          parameters: params
        )
      )
    }
  }

  private func logPaywallDismissed(
    state: State
  ) -> EffectTask<Action> {
    var params: [Analytics.ParameterName: Any] = [:]
    params[.contentID] = state.paywallID
    params[.placement] = state.placement

    return .fireAndForget {
      analytics.log(
        .event(
          eventName: "paywall_dismissed",
          parameters: params
        )
      )
    }
  }
}
