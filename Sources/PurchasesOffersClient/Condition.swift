import DuckPurchasesCore
import Foundation

struct PurchasesOfferCondition {
  var calculateOffer: @Sendable (
    _ at: Date,
    _ paywallType: Paywall.PaywallType?
  ) async -> PurchasesOffer?
}
