import DuckRemoteSettingsClient

extension RemoteSettingsClient {

  public var paywallPromoOffer: Paywall.PromoOffer? {
    let string = stringForKey(Self.paywallPromoOffer)
    guard let string, !string.isEmpty else { return nil }

    return Paywall.PromoOffer(string)
  }
}

extension RemoteSettingsClient {
  public static var paywallPromoOffer: String {
    "paywall_promo_offer"
  }
}
