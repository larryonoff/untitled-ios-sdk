import ComposableArchitecture
import DuckAnalyticsClient
import DuckComposableArchitecture
import DuckFeedbackClient
import DuckPaywallTargeting
import DuckPurchases
import Foundation
import IdentifiedCollections

@Reducer
public struct PaywallReducer: Sendable {
  public enum Action {
    public enum Delegate {
      case dismiss
    }

    case delegate(Delegate)

    case onAppear
    case onDisappear

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

    public var target: Paywall.Target
    public var paywall: Paywall?

    public var products: IdentifiedArrayOf<Product> = []
    public var productComparing: Product?
    public var productSelectedID: Product.ID?

    public var placement: Placement?

    /// When the paywall first showed its products, for `seconds_on_screen`.
    var viewedAt: Date?

    // MARK: - Calculated Props

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
    @Shared(.offerHistory) public var offerHistory

    // MARK: Init

    /// Creates the state for a paywall chosen by
    /// `@Dependency(\.paywallTargeting)`, e.g.
    /// `.init(target: paywallTargeting.paywall(for: placement), placement: placement)`.
    public init(target: Paywall.Target, placement: Placement?) {
      self.target = target
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

  @Reducer
  public enum Destination {
    case alert(AlertState<Alert>)
    case postDeclineIntroOffer(PostDeclineIntroOffer)

    public enum Alert: Equatable {
      case dismissPaywall
      case retryFetchPaywall
      case retryPurchase
      case retryRestorePurchases
    }
  }

  private enum CancelID: Hashable {
    case purchase
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.date) var date
  @Dependency(\.feedback) var feedback
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
        return fetchPaywall(state: &state)
      case .onDisappear:
        return .none

      case .cancelPurchaseTapped:
        return purchaseCancel(state: &state)
      case .dismissTapped:
        if presentPostDeclineIntroOfferIfNeeded(&state) {
          return .none
        }

        return close(.closeButton, state: &state)
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
          let isFirstShown = state.paywall == nil && paywall != nil

          state.update(paywall)

          var effects: [Effect<Action>] = []

          if isFirstShown {
            state.viewedAt = date.now
            effects.append(analytics.logView(state: state))
          }

          if let paywall, paywallChanged {
            effects.append(
              .run { _ in
                try await purchases.log(paywall)
              }
            )
          }

          return .merge(effects)
        } catch {
          state.paywall = nil
          state.productSelectedID = nil
          // Onboarding gets no dismiss action: without a paywall there is
          // nothing to show, and letting OK close it would be a way out of the
          // funnel. Everywhere else the paywall is escapable, so it stays so.
          state.destination = .alert(
            .failure(
              error,
              retryAction: .retryFetchPaywall,
              dismissAction: state.target.kind.isOnboarding ? nil : .dismissPaywall
            )
          )
        }

        return .none
      case let .purchaseResponse(result, product):
        state.isPurchasing = false

        do {
          switch try result.get() {
          case .pending, .success:
            return .concatenate(
              analytics.logPurchase(
                .success,
                product: product,
                paywallID: state.target.id,
                placement: state.placement
              ),
              .send(.delegate(.dismiss))
            )
          case .userCancelled:
            return analytics.logPurchase(
              .cancelled,
              product: product,
              paywallID: state.target.id,
              placement: state.placement
            )
          }
        } catch {
          state.destination = .alert(
            .failure(error, retryAction: .retryPurchase)
          )

          // No haptic on success: the system purchase sheet confirms it with
          // its own. A failure is ours to report, alongside the alert.
          return .merge(
            playError(),
            analytics.logPurchase(
              .failure,
              product: product,
              paywallID: state.target.id,
              placement: state.placement,
              error: error
            )
          )
        }
      case let .restorePurchasesResponse(result):
        state.isPurchasing = false

        do {
          let restoreResult = try result.get()
          let logRestore: Effect<Action> = analytics.logRestore(
            RestoreAction(restoreResult),
            paywallID: state.target.id,
            placement: state.placement
          )

          switch restoreResult {
          case .success:
            // The paywall just closes on a restore, so without this nothing
            // says it worked.
            return .merge(
              logRestore,
              .run { [feedback] _ in await feedback(.notification(.success)) },
              close(.restore, state: &state)
            )
          case .userCancelled:
            return logRestore
          }
        } catch {
          state.destination = .alert(
            .failure(error, retryAction: .retryRestorePurchases)
          )

          return .merge(
            playError(),
            analytics.logRestore(
              .failure,
              paywallID: state.target.id,
              placement: state.placement,
              error: error
            )
          )
        }

      case .destination(.dismiss):
        let isPostDeclinePresented = state.destination?.is(\.postDeclineIntroOffer) == true

        state.destination = nil

        // Swiping the offer away declines it, same as its close button.
        if isPostDeclinePresented {
          return close(.introOfferDeclined, state: &state)
        }

        return .none
      case .destination(.presented(.postDeclineIntroOffer(.delegate(.declined)))):
        return close(.introOfferDeclined, state: &state)
      case .destination(.presented(.postDeclineIntroOffer(.delegate(.purchased)))):
        return dismiss(state: &state)
      case .destination(.presented(.postDeclineIntroOffer(.delegate(.restored)))):
        return close(.restore, state: &state)
      case .destination(.presented(.alert(.dismissPaywall))):
        return dismiss(state: &state)
      case .destination(.presented(.alert(.retryFetchPaywall))):
        return fetchPaywall(state: &state)
      case .destination(.presented(.alert(.retryPurchase))):
        return purchase(state: &state)
      case .destination(.presented(.alert(.retryRestorePurchases))):
        return restorePurchases(state: &state)
      case .destination:
        return .none

      case let .products(.element(id: productID, action: .tapped)):
        // Only a tap that moves the selection clicks. Tapping the selected plan
        // buys it, and the purchase answers for itself; the default selection
        // is the paywall's choice, not the user's.
        let isSelectionChange = productID != state.productSelectedID
        let effect = selectProduct(withID: productID, state: &state)
        guard isSelectionChange else { return effect }

        return .merge(
          effect,
          .run { [feedback] _ in await feedback(.selection) }
        )
      }
    }
  }

  // MARK: - Effects

  /// The paywall closes without a purchase.
  private func close(
    _ action: PaywallAction,
    state: inout State
  ) -> Effect<Action> {
    let logClose: Effect<Action> = analytics.logClose(action, state: state, now: date.now)
    return .merge(logClose, dismiss(state: &state))
  }

  /// A purchase or restore the user started has failed.
  private func playError() -> Effect<Action> {
    .run { [feedback] _ in await feedback(.notification(.error)) }
  }

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

    return .run(priority: .high) { [paywallID = state.target.id] send in
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
    // `purchase` and `restorePurchases` share a cancel ID, so a second request
    // arriving mid-flight would cancel the first rather than queue behind it.
    guard !state.isPurchasing else {
      return .none
    }

    state.isPurchasing = true

    return .merge(
      analytics.logPurchase(
        .attempt,
        product: product,
        paywallID: state.target.id,
        placement: state.placement
      ),
      .run { [paywallID = state.target.id] send in
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
        paywallID: state.target.id,
        placement: state.placement
      ),
      .run { send in
        let result = await Result {
          try await purchases.restorePurchases()
        }

        await send(.restorePurchasesResponse(result))
      }
      .cancellable(id: CancelID.purchase, cancelInFlight: true)
    )
  }

  private func selectProduct(
    withID productID: Product.ID?,
    state: inout State
  ) -> Effect<Action> {
    let productChanged = productID != state.productSelected?.id

    state.productSelectedID = productID

    guard let product = state.productSelected else {
      return .none
    }

    guard productChanged else {
      return purchase(product, state: &state)
    }

    return analytics.logProductSelect(product, state: state)
  }
}

extension PaywallReducer.Destination.State: Equatable {}
