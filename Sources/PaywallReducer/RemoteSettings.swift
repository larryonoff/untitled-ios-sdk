import DuckRemoteSettingsClient

extension RemoteSettingsClient {
  public var isSubsHiddenPricesEnabled: Bool {
    boolForKey("subs_hidden_price_enabled") ?? true
  }

  public var isSubsOnboardingIntroOfferEnabled: Bool {
    boolForKey("subs_onboarding_intro_offer_enabled") ?? true
  }

  public var isSubsOnboardingEnabled: Bool {
    boolForKey("subs_onboarding_enabled") ?? true
  }
}
