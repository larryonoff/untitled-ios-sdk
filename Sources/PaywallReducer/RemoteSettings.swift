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

extension PersistenceReaderKey where Self == PersistenceKeyDefault<RemoteSettingKey<Bool>> {
  public static var isPaywallProductHiddenPricesEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting("paywall_product_hidden_price_enabled"),
      true
    )
  }

  public static var isPaywallOnboardingIntroOfferEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting("paywall_onboarding_intro_offer_enabled"),
      true
    )
  }

  public static var isPaywallOnboardingEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting("paywall_onboarding_enabled"),
      true
    )
  }
}
