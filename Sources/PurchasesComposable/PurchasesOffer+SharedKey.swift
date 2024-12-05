import Dependencies
@_exported import DuckPurchasesOffersClient
import Sharing

extension SharedReaderKey where Self == PurchasesOfferKey {
  public static var purchasesOffer: Self {
    PurchasesOfferKey()
  }
}

public struct PurchasesOfferKey: SharedReaderKey, Sendable {
  public typealias Value = PurchasesOffer?

  @Dependency(\.purchasesOffers) var purchasesOffers

  public init() {}

  public var id: PurchasesOfferKeyID {
    PurchasesOfferKeyID()
  }

  public func load(
    initialValue: Value?
  ) -> Value? {
    purchasesOffers.activeOffer()
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (_ newValue: Value?) -> Void
  ) -> SharedSubscription {
    let task = Task {
      for await offer in purchasesOffers.activeOfferUpdates() {
        receiveValue(offer)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct PurchasesOfferKeyID: Hashable {}
