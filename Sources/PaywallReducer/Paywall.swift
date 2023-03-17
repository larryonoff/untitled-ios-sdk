import AnalyticsClient
import ComposableArchitecture
import ComposableArchitectureExt
import IdentifiedCollections
import PurchasesClient

public struct PaywallReducer: ReducerProtocol {
  public enum Action: Equatable {
    public enum AlertAction: Equatable {
      case dismissed
    }

    public enum Delegate: Equatable {
      case dismissed
    }

    public enum ProductAction: Equatable {
      case tapped
    }

    case onAppear
    case delegate(Delegate)

    case alert(AlertAction)

    case dismissTapped

    case fetchPaywallResponse(TaskResult<Paywall?>)

    case oneTimeOfferDismissed

    case product(id: Product.ID, action: ProductAction)

    case purchase
    case purchaseCancelled
    case purchaseResponse(TaskResult<PurchaseResult>)

    case restorePurchases
    case restorePurchasesResponse(TaskResult<RestorePurchasesResult>)
  }

  public struct State: Equatable {
    public struct OneTimeOffer: Equatable {
      public var isEligibleForIntroductoryOffer: Bool
      public var product: Product?
    }

    @Box public var alert: AlertState<Action>?

    @Box public var oneTimeOffer: OneTimeOffer?

    public let paywallID: Paywall.ID
    @Box public var paywall: Paywall?

    @Box public var products: IdentifiedArrayOf<Product> = []
    @Box public var productComparing: Product?
    @Box public var productSelected: Product?

    @Box public var placement: Placement?

    @Box public var isEligibleForIntroductoryOffer: Bool = false
    @Box public var isFetchingPaywall: Bool = false
    @Box public var isOneTimeOfferEnabled: Bool = false
    @Box public var isPurchasing: Bool = false

    var canPresentOneTimeOffer: Bool {
      isOneTimeOfferEnabled && paywall?.payUpFrontProductID != nil
    }

    var isOneTimeOfferPresented: Bool {
      oneTimeOffer != nil
    }

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
        state.isEligibleForIntroductoryOffer =
          purchases.purchases().isEligibleForIntroductoryOffer
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
      case .delegate:
        return .none
      case .dismissTapped:
        if
          !state.isOneTimeOfferPresented,
          state.canPresentOneTimeOffer,
          let oneTimeProduct = state.paywall?.payUpFrontProduct
        {
          let oneTimeOffer = State.OneTimeOffer(
            isEligibleForIntroductoryOffer: state.isEligibleForIntroductoryOffer,
            product: oneTimeProduct
          )
          state.oneTimeOffer = oneTimeOffer

          return .none
        }

        return .merge(
          logPaywallDismissed(state: state),
          .send(.delegate(.dismissed))
        )
      case let .fetchPaywallResponse(result):
        state.isFetchingPaywall = false

        do {
          let paywall = try result.value
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
        } catch {
          state.paywall = nil
          state.productSelected = nil
          state.alert = .failure(error)
        }

        return .none
      case .oneTimeOfferDismissed:
        return .send(.delegate(.dismissed))
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
          switch try result.value {
          case .success:
            return .send(.delegate(.dismissed))
          case .userCancelled:
            return .none
          }
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
          switch try result.value {
          case .success:
            return .send(.delegate(.dismissed))
          case .userCancelled:
            return .none
          }
        } catch {
          state.alert = .failure(error)
        }

        return .none
      case .alert(.dismissed):
        state.alert = nil
        return .none
      }
    }
  }

  // MARK: - Effects

  private func purchase(
    _ product: Product,
    state: inout State
  ) -> EffectTask<Action> {
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
