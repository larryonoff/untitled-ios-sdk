import Dependencies
import DependenciesMacros
import DuckCore
import DuckPurchasesCore
import Tagged

extension DependencyValues {
  public var paywallTargeting: PaywallTargeting {
    get { self[PaywallTargeting.self] }
    set { self[PaywallTargeting.self] = newValue }
  }
}

/// Decides which paywall a placement shows.
///
/// Each app provides its own live value, because the rules and the purchases
/// provider's placement IDs are app-specific:
/// `extension PaywallTargeting: @retroactive DependencyKey { static let liveValue = … }`.
@DependencyClient
public struct PaywallTargeting: Sendable {
  /// The paywall to show at a placement, taking the active offer into account.
  @DependencyEndpoint(method: "paywall")
  public var paywallForPlacement: @Sendable (
    _ for: Placement?
  ) -> Paywall.Target = { _ in .init(kind: .main, id: "") }

  /// The paywall that presents a kind, e.g. the special-offer paywall the
  /// offers refresh prefetches.
  @DependencyEndpoint(method: "paywall")
  public var paywallForKind: @Sendable (
    _ forKind: Paywall.Kind
  ) -> Paywall.Target = { .init(kind: $0, id: "") }
}
