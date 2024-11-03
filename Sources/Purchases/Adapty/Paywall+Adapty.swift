import Adapty

package extension Paywall {
  init(
    _ paywall: AdaptyPaywall,
    products: [AdaptyPaywallProduct]?
  ) {
    self.init(
      id: .init(paywall.placementId),
      products: products?
        .compactMap { .init($0) } ?? [],
      remoteConfigString: paywall.remoteConfig?.jsonString
    )
  }
}
