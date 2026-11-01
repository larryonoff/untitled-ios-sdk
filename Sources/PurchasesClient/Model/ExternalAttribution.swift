import Foundation

extension PurchasesClient {
  /// Attribution data from an attribution provider, forwarded as the provider reported it.
  public struct ExternalAttribution: Sendable {
    public let provider: Provider
    /// The provider's attribution dictionary, unchanged.
    public let dictionary: [String: any Sendable]

    /// Values retain their immutable, Sendable representation until the provider adapter.
    public init(provider: Provider, dictionary: [String: any Sendable]) {
      self.provider = provider
      self.dictionary = dictionary
    }
  }
}

extension PurchasesClient.ExternalAttribution {
  public struct Provider: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public static let adjust = Self(rawValue: "adjust")
  }
}
