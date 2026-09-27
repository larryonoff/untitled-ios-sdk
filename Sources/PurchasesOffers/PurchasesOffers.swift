import ComposableArchitecture
import DuckPaywallTargeting
import DuckPurchasesClient
import DuckRemoteSettingsClient

/// Keeps ``OfferAvailability`` fresh. Compose it at the app root and send
/// ``Action/refresh`` at launch and whenever the scene becomes active.
@Reducer
public struct PurchasesOffers: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    @Shared(.offerAvailability) public var availability

    public init() {}
  }

  public enum Action: Sendable {
    case refresh
    case refreshResponse(OfferAvailability)
  }

  enum CancelID {
    case refresh
  }

  @Dependency(\.paywallTargeting) var paywallTargeting
  @Dependency(\.purchases) var purchases
  @Dependency(\.remoteSettings) var remoteSettings

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .refresh:
        return .run { send in
          await send(.refreshResponse(await availability()))
        }
        // A slow refresh must not land after a newer one.
        .cancellable(id: CancelID.refresh, cancelInFlight: true)

      case let .refreshResponse(availability):
        state.$availability.withLock { $0.merge(availability) }
        return .none
      }
    }
  }
}
