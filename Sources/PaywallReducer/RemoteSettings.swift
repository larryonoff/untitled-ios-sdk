import ComposableArchitecture
import DuckRemoteSettingsClient
import DuckRemoteSettingsComposable

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

extension PersistenceReaderKey where Self == RemoteSettingKey<Bool> {
  public static var isPaywallProductHiddenPricesEnabled: Self {
    remoteSetting("paywall_product_hidden_price_enabled")
  }

  public static var isPaywallOnboardingIntroOfferEnabled: Self {
    remoteSetting("paywall_onboarding_intro_offer_enabled")
  }

  public static var isPaywallOnboardingEnabled: Self {
    remoteSetting("paywall_onboarding_enabled")
  }
}
