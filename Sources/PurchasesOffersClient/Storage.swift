import Foundation

extension UserDefaults {
  static var wasLimitedTimeOfferActiveKey: String { "wasLimitedTimeOfferActiveDisabled" }
  static var wasMainPaywallDismissedKey: String { "wasMainPaywallDismissed" }
  static var purchasesOfferKey: String { "purchasesOffer" }

  var wasLimitedTimeOfferActive: Bool {
    get { bool(forKey: Self.wasLimitedTimeOfferActiveKey) }
    set { set(newValue, forKey: Self.wasLimitedTimeOfferActiveKey) }
  }

  var wasMainPaywallDismissed: Bool {
    get { bool(forKey: Self.wasMainPaywallDismissedKey) }
    set { set(newValue, forKey: Self.wasMainPaywallDismissedKey) }
  }

  var purchasesOffer: PurchasesOffer? {
    get {
      do {
        guard let data = data(forKey: Self.purchasesOfferKey) else {
          return nil
        }
        return try JSONDecoder().decode(PurchasesOffer.self, from: data)
      } catch {
        return nil
      }
    }
    set {
      do {
        if let newValue {
          let data = try JSONEncoder().encode(newValue)
          set(data, forKey: Self.purchasesOfferKey)
        } else {
          set(nil, forKey: Self.purchasesOfferKey)
        }
      } catch {
        set(nil, forKey: Self.purchasesOfferKey)
      }
    }
  }
}
