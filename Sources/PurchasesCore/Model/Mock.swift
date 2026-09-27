import Foundation

extension Paywall {
  static let mock = Paywall(
    id: .init("mock"),
    abTestName: nil,
    audienceName: nil,
    products: [
      .mockYear,
      .mockMonth
    ]
  )
}

extension Product.ID {
  static let mockYear: Self = .init("year")
  static let mockMonth: Self = .init("month")
}

extension Product {
  static let mockYear: Product = {
    var product = Product(
      id: .mockYear,
      displayName: "Year Subscription Name",
      description: "Year Subscription Description",
      price: 19.99,
      priceLocale: .enUS,
      displayPrice: "19.99$",
      subscription: .init(
        introductoryOffer: .init(
          id: "year-intro-offer",
          type: .introductory,
          price: 0,
          displayPrice: "0",
          period: .day(3),
          periodCount: 1,
          paymentMode: .freeTrial
        ),
        promotionalOffers: [],
        winBackOffers: [],
        subscriptionGroupID: "subscriptionGroupID",
        subscriptionPeriod: .year(1),
        isEligibleForIntroOffer: true
      )
    )
    // What Adapty attaches for a user who hasn't used the trial yet.
    product.subscriptionOffer = product.subscription?.introductoryOffer
    return product
  }()

  static let mockMonth = Product(
    id: .mockMonth,
    displayName: "Month Subscription Name",
    description: "Month Subscription Description",
    price: 1.99,
    priceLocale: .enUS,
    displayPrice: "1.99$",
    subscription: .init(
      introductoryOffer: nil,
      promotionalOffers: [],
      winBackOffers: [],
      subscriptionGroupID: "subscriptionGroupID",
      subscriptionPeriod: .month(1),
      isEligibleForIntroOffer: false
    )
  )
}

extension Locale {
  static let enUS = Locale(identifier: "en-US")
}
