import ComposableArchitecture
import DuckRemoteSettingsClient
import DuckRemoteSettingsComposable
import Model

extension PersistenceReaderKey where Self == PersistenceKeyDefault<RemoteSettingKey<Bool>> {
  public static var isPaywallProductHiddenPricesEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting(RemoteSettingsClient.isPaywallProductHiddenPricesEnabledKey),
      true
    )
  }

  public static var isPaywallOnboardingIntroOfferEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting(RemoteSettingsClient.isPaywallOnboardingIntroOfferEnabledKey),
      true
    )
  }

  public static var isPaywallOnboardingEnabled: Self {
    PersistenceKeyDefault(
      .remoteSetting(RemoteSettingsClient.isPaywallOnboardingEnabledKey),
      true
    )
  }
}

extension PersistenceReaderKey where Self == RemoteSettingKey<Paywall.PromoOfferType?> {
  public static var paywallPromoOfferType: Self {
    .remoteSetting(RemoteSettingsClient.paywallPromoOfferType)
  }
}
