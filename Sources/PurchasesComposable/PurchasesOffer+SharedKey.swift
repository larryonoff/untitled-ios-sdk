import Dependencies
@_exported import DuckPurchasesOffersClient
import Sharing

extension SharedReaderKey where Self == PurchasesOfferKey {
  public static var purchasesOffer: Self {
    PurchasesOfferKey()
  }
}

public struct PurchasesOfferKey: SharedReaderKey, Sendable {
  @Dependency(\.purchasesOffers) var purchasesOffers

  public init() {}

  public typealias Value = PurchasesOffer?

  public var id: PurchasesOfferKeyID {
    PurchasesOfferKeyID()
  }

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resume(with: .success(purchasesOffers.activeOffer()))
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    let task = Task {
      for await value in purchasesOffers.activeOfferUpdates() {
        subscriber.yield(with: .success(value))
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct PurchasesOfferKeyID: Hashable {}
