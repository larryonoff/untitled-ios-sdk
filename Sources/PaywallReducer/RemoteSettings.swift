import DuckRemoteSettingsClient

extension RemoteSettingsClient {
  public var isPaywallProductHiddenPricesEnabled: Bool {
    boolForKey("paywall_product_hidden_price_enabled") ?? true
  }

  public var isPaywallOnboardingIntroOfferEnabled: Bool {
    boolForKey("paywall_onboarding_intro_offer_enabled") ?? true
  }

  public var isPaywallOnboardingEnabled: Bool {
    boolForKey("paywall_onboarding_enabled") ?? true
  }
}
