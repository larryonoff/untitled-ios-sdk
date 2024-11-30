import ComposableArchitecture
@_exported import DuckPurchasesOffersClient

extension PersistenceReaderKey where Self == PersistenceKeyDefault<PurchasesOfferPersistenceKey> {
  public static var purchasesOffer: Self {
    PersistenceKeyDefault(PurchasesOfferPersistenceKey(), nil)
  }
}

public struct PurchasesOfferPersistenceKey: PersistenceReaderKey, Sendable {
  public typealias Value = PurchasesOffer?

  @Dependency(\.purchasesOffers) var purchasesOffers

  public init() {}

  public var id: AnyHashable {
    PurchasesOfferPersistenceKeyID()
  }

  public func load(
    initialValue: Value?
  ) -> Value? {
    purchasesOffers.activeOffer()
  }

  public func subscribe(
    initialValue: Value?,
    didSet: @escaping (Value?) -> Void
  ) -> Shared<Value>.Subscription {
    let task = Task {
      for await offer in purchasesOffers.activeOfferUpdates() {
        didSet(offer)
      }
    }

    return Shared.Subscription {
      task.cancel()
    }
  }
}

private struct PurchasesOfferPersistenceKeyID: Hashable {}
