import DuckRemoteSettingsClient

extension RemoteSettingsClient {
  public var isIntroductoryOfferEnabled: Bool {
    boolForKey(Self.isIntroductoryOfferEnabledKey) ?? true
  }

  public var isLimitedTimeOfferEnabled: Bool {
    boolForKey(Self.isLimitedTimeOfferEnabledKey) ?? true
  }

  public var isPaywallProductHiddenPricesEnabled: Bool {
    boolForKey(Self.isPaywallProductHiddenPricesEnabledKey) ?? true
  }

  public var isPaywallOnboardingIntroOfferEnabled: Bool {
    boolForKey(Self.isPaywallOnboardingIntroOfferEnabledKey) ?? true
  }

  public var isPaywallOnboardingEnabled: Bool {
    boolForKey(Self.isPaywallOnboardingEnabledKey) ?? true
  }

  /// When off, an offer backed only by a promotional offer isn't shown:
  /// Adapty attaches promotional offers without checking eligibility.
  public var isPromoOfferEnabled: Bool {
    boolForKey(Self.isPromoOfferEnabledKey) ?? true
  }

  /// The seasonal offer to run instead of the default limited-time one, e.g.
  /// `.Offer.blackFriday`.
  public var paywallSpecialOffer: Paywall.Kind? {
    guard let string = stringForKey(Self.paywallSpecialOfferKey), !string.isEmpty else {
      return nil
    }
    return Paywall.Kind(string)
  }
}

extension RemoteSettingsClient {
  public static let isIntroductoryOfferEnabledKey = "paywall_introductory_offer_enabled"
  public static let isLimitedTimeOfferEnabledKey = "paywall_limited_time_offer_enabled"
  public static let isPaywallProductHiddenPricesEnabledKey = "paywall_product_hidden_price_enabled"
  public static let isPaywallOnboardingIntroOfferEnabledKey = "paywall_onboarding_intro_offer_enabled"
  public static let isPaywallOnboardingEnabledKey = "paywall_onboarding_enabled"
  public static let isPromoOfferEnabledKey = "paywall_promo_offer_enabled"
  public static let paywallSpecialOfferKey = "paywall_special_offer"
}
