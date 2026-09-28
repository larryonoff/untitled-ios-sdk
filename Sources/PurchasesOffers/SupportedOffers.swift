import Dependencies
import DuckPurchasesCore

extension DependencyValues {
  public var supportedOffers: SupportedOffers {
    get { self[SupportedOffers.self] }
    set { self[SupportedOffers.self] = newValue }
  }
}

/// The offers an app has paywalls for. An offer outside the set is unavailable
/// whatever remote config says; one inside can still be switched off remotely.
///
/// Each app provides its own live value, because which offers it has paywalls
/// for is app-specific:
/// `extension SupportedOffers: @retroactive DependencyKey { static let liveValue: Self = [.Offer.blackFriday] }`.
public struct SupportedOffers: Equatable, Sendable {
  private var kinds: Set<Paywall.Kind>

  public init(_ kinds: Set<Paywall.Kind>) {
    self.kinds = kinds
  }

  public func contains(_ kind: Paywall.Kind) -> Bool {
    kinds.contains(kind)
  }
}

extension SupportedOffers: ExpressibleByArrayLiteral {
  public init(arrayLiteral kinds: Paywall.Kind...) {
    self.init(Set(kinds))
  }
}

extension SupportedOffers: TestDependencyKey {
  public static let previewValue = Self.testValue

  /// No offers: an app opts into the ones it has paywalls for.
  public static let testValue: Self = []
}
