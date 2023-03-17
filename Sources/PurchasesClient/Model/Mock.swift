import Foundation

extension Paywall {
  static let mock = Paywall(
    id: .init("mock"),
    products: [
      .mockYear,
      .mockMonth
    ],
    productComparingID: .mockMonth,
    productSelectedID: .mockYear,
    payUpFrontProductID: nil,
    variantID: nil
  )
}

extension Product.ID {
  static let mockYear: Self = .init("year")
  static let mockMonth: Self = .init("month")
}

extension Product {
  static let mockYear = Product(
    id: .mockYear,
    displayName: "Year Subscription Name",
    description: "Year Subscription Description",
    price: 19.99,
    priceLocale: .en_US,
    displayPrice: "19.99$",
    subscriptionInfo: .init(
      introductoryOffer: .init(
        id: "year-intro-offer",
        type: .introductory,
        price: 0,
        priceLocale: .en_US,
        displayPrice: "0",
        period: .day(3),
        paymentMode: .freeTrial
      ),
      subscriptionGroupID: "subscriptionGroupID",
      subscriptionPeriod: .year(1)
    )
  )

  static let mockMonth = Product(
    id: .mockMonth,
    displayName: "Month Subscription Name",
    description: "Month Subscription Description",
    price: 1.99,
    priceLocale: .en_US,
    displayPrice: "1.99$",
    subscriptionInfo: .init(
      introductoryOffer: nil,
      subscriptionGroupID: "subscriptionGroupID",
      subscriptionPeriod: .month(1)
    )
  )
}

extension Locale {
  static let en_US = Locale(identifier: "en-US")
}
