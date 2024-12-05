import Foundation

extension Product.SubscriptionOffer.PaymentMode {
  public struct FormatStyle {
    public init() {}
  }
}

extension Product.SubscriptionOffer.PaymentMode.FormatStyle: Foundation.FormatStyle {
  public func format(
    _ value: Product.SubscriptionOffer.PaymentMode
  ) -> String {
    switch value {
    case .freeTrial:
      return L10n.Product.SubscriptionOffer.PaymentMode.freeTrial
    case .payAsYouGo:
      return L10n.Product.SubscriptionOffer.PaymentMode.payAsYouGo
    case .payUpFront:
      return L10n.Product.SubscriptionOffer.PaymentMode.payUpFront
    }
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == Product.SubscriptionOffer.PaymentMode {
    style.format(self)
  }
}

extension Product.SubscriptionOffer.PaymentMode.FormatStyle: Codable {}
extension Product.SubscriptionOffer.PaymentMode.FormatStyle: Equatable {}
extension Product.SubscriptionOffer.PaymentMode.FormatStyle: Sendable {}
extension Product.SubscriptionOffer.PaymentMode.FormatStyle: Hashable {}
