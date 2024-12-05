import DuckRemoteSettingsClient
import DuckRemoteSettingsComposable
import Model
import Sharing

extension SharedReaderKey where Self == RemoteSettingKey<Bool>.Default {
  public static var isPaywallProductHiddenPricesEnabled: Self {
    Self[
      .remoteSetting(RemoteSettingsClient.isPaywallProductHiddenPricesEnabledKey),
      default: true
    ]
  }

  public static var isPaywallOnboardingIntroOfferEnabled: Self {
    Self[
      .remoteSetting(RemoteSettingsClient.isPaywallOnboardingIntroOfferEnabledKey),
      default: true
    ]
  }

  public static var isPaywallOnboardingEnabled: Self {
    Self[
      .remoteSetting(RemoteSettingsClient.isPaywallOnboardingEnabledKey),
      default: true
    ]
  }
}
