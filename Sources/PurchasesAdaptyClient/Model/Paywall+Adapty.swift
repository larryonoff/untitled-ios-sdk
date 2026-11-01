import Adapty
import DuckPurchasesCore
import Foundation
import StoreKit

extension Paywall {
  package init(
    _ flow: AdaptyFlow,
    products: [AdaptyPaywallProduct]?
  ) {
    self.init(
      id: .init(flow.placement.id),
      abTestName: flow.placement.abTestName,
      audienceName: flow.placement.audienceName,
      variationID: flow.variationId,
      variationName: flow.variationName,
      products: products?.compactMap { DuckPurchasesCore.Product($0) } ?? [],
      remoteConfigString: flow.remoteConfigs.jsonString()
    )
  }
}

private extension [AdaptyRemoteConfig] {
  /// Raw payload for `locale`, falling back to English and then to any
  /// configured one.
  ///
  /// A flow carries one config per locale and `getFlow` is locale-agnostic, so
  /// picking one is up to us. English is the fallback because that is what the
  /// dashboard always fills in. Locales match on language code, so an `en`
  /// config satisfies `en-US` and `en_GB` alike.
  func jsonString(for locale: Locale = .current) -> String? {
    let languageCode = locale.identifier.adaptyLanguageCode

    let config = first { $0.locale.adaptyLanguageCode == languageCode }
      ?? first { $0.locale.adaptyLanguageCode == "en" }
      ?? first

    return config?.jsonString
  }
}

private extension String {
  /// Language code of a locale identifier — everything before the first region
  /// separator, matching how Adapty compares locales internally.
  var adaptyLanguageCode: String {
    prefix { !["-", "_"].contains($0) }.lowercased()
  }
}
