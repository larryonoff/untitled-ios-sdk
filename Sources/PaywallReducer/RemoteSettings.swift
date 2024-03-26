import DuckRemoteSettingsClient

extension RemoteSettingsClient {
  public var isHiddenPricesEnabled: Bool {
    boolForKey("subs_hidden_price_enabled") ?? true
  }

  public var isIntroductoryOfferEnabled: Bool {
    boolForKey("subs_intro_offer_enabled") ?? true
  }

  public var isOnboardingPaywallEnabled: Bool {
    boolForKey("subs_onboarding_enabled") ?? true
  }
}
