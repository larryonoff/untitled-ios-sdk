import DuckRemoteSettingsClient

extension RemoteSettingsClient {
  public var isPaywallProductHiddenPricesEnabled: Bool {
    boolForKey(Self.isPaywallProductHiddenPricesEnabledKey) ?? true
  }

  public var isPaywallOnboardingIntroOfferEnabled: Bool {
    boolForKey(Self.isPaywallOnboardingIntroOfferEnabledKey) ?? true
  }

  public var isPaywallOnboardingEnabled: Bool {
    boolForKey(Self.isPaywallOnboardingEnabledKey) ?? true
  }

  public var paywallPromoOffer: Paywall.PromoOffer? {
    let string = stringForKey(Self.paywallPromoOffer)
    guard let string, !string.isEmpty else { return nil }

    return Paywall.PromoOffer(string)
  }
}

extension RemoteSettingsClient {
  public static var isPaywallProductHiddenPricesEnabledKey: String {
    "paywall_product_hidden_price_enabled"
  }

  public static var isPaywallOnboardingIntroOfferEnabledKey: String {
    "paywall_onboarding_intro_offer_enabled"
  }

  public static var isPaywallOnboardingEnabledKey: String {
    "paywall_onboarding_enabled"
  }

  public static var paywallPromoOffer: String {
    "paywall_promo_offer"
  }
}
