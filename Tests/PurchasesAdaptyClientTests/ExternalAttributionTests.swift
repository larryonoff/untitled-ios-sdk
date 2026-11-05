import Adapty
import DuckPurchasesClient
import Testing

struct ExternalAttributionTests {
  @Test(arguments: [
    (PurchasesClient.ExternalAttribution.Provider.adjust, AdaptyExternalAttributionProvider.adjust),
    (.appleAds, .appleAds),
    (.appsFlyer, .appsflyer),
    (.branch, .branch),
    (.custom, .custom),
    (.tenjin, .tenjin)
  ])
  func `each provider is the one Adapty knows under the same name`(
    provider: PurchasesClient.ExternalAttribution.Provider,
    adaptyProvider: AdaptyExternalAttributionProvider
  ) {
    #expect(AdaptyExternalAttributionProvider(rawValue: provider.rawValue) == adaptyProvider)
  }
}
