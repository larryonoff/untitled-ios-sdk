import CustomDump
@testable import DuckPurchasesCore
import Foundation
import Testing

struct EligibilityTests {
  @Test func storeTrialWithoutAttachedOfferIsNotEligible() {
    // The product has a trial in App Store Connect, but Adapty attached no
    // offer: the user has already used it.
    var product = Product.mockYear
    product.subscriptionOffer = nil
    #expect(product.hasIntroFreeTrial)
    #expect(!product.isEligibleForIntroFreeTrial)
  }

  @Test func attachedIntroductoryFreeTrialIsEligible() {
    var product = Product.mockYear
    product.subscriptionOffer = .mock(type: .introductory, paymentMode: .freeTrial)
    #expect(product.isEligibleForIntroFreeTrial)
  }

  @Test func attachedIntroductoryPaidOfferIsNotAFreeTrial() {
    var product = Product.mockYear
    product.subscriptionOffer = .mock(type: .introductory, paymentMode: .payAsYouGo)
    #expect(!product.isEligibleForIntroFreeTrial)
  }

  @Test func attachedPromotionalFreePeriodIsNotAnIntroFreeTrial() {
    var product = Product.mockYear
    product.subscriptionOffer = .mock(type: .promotional, paymentMode: .freeTrial)
    #expect(!product.isEligibleForIntroFreeTrial)
  }

  @Test func eligibleOffersListIntroductoryFirstKeepingOrder() {
    let promo = Product.mock(id: "promo", offer: .mock(type: .promotional, paymentMode: .payAsYouGo))
    let introA = Product.mock(id: "intro-a", offer: .mock(type: .introductory, paymentMode: .freeTrial))
    let none = Product.mock(id: "none", offer: nil)
    let introB = Product.mock(id: "intro-b", offer: .mock(type: .introductory, paymentMode: .payUpFront))
    let paywall = Paywall(
      id: "test",
      abTestName: nil,
      audienceName: nil,
      products: [promo, introA, none, introB]
    )

    expectNoDifference(
      paywall.eligibleOffers.map(\.product.id),
      ["intro-a", "intro-b", "promo"]
    )
  }
}

private extension Product {
  static func mock(id: Product.ID, offer: Product.SubscriptionOffer?) -> Self {
    var product = Product.mockMonth
    product.id = id
    product.subscriptionOffer = offer
    return product
  }
}

private extension Product.SubscriptionOffer {
  static func mock(type: OfferType, paymentMode: PaymentMode) -> Self {
    .init(
      id: nil,
      type: type,
      price: 0,
      displayPrice: "0",
      period: .week(1),
      periodCount: 1,
      paymentMode: paymentMode
    )
  }
}
