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
