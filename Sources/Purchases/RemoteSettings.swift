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

  public var paywallPromoOfferType: Paywall.PromoOfferType? {
    let string = stringForKey(Self.paywallPromoOfferType)
    guard let string, !string.isEmpty else { return nil }

    return Paywall.PromoOfferType(string)
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

  public static var paywallPromoOfferType: String {
    "paywall_promo_offer"
  }
}
