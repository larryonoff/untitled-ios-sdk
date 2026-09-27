import Dependencies
import DuckPurchasesCore
import Tagged

extension PaywallTargeting: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension PaywallTargeting {
  public static let noop = Self(
    paywallForPlacement: { _ in .init(kind: .main, id: "") },
    paywallForKind: { .init(kind: $0, id: "") }
  )
}
