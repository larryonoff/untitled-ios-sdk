import Adapty
import DuckPurchasesClient
import Testing

struct ExternalAttributionTests {
  @Test func `the Adjust provider is the one Adapty knows as Adjust`() {
    let provider = PurchasesClient.ExternalAttribution.Provider.adjust

    #expect(AdaptyExternalAttributionProvider(rawValue: provider.rawValue) == .adjust)
  }
}
