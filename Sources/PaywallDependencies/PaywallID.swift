import Dependencies
import DuckPurchasesCore

extension DependencyValues {
  public var paywallID: PaywallIDGenerator {
    get { self[PaywallIDGeneratorKey.self] }
    set { self[PaywallIDGeneratorKey.self] = newValue }
  }

  private enum PaywallIDGeneratorKey: DependencyKey {
    static let liveValue = PaywallIDGenerator { _ in "" }
    static let testValue = PaywallIDGenerator { _ in
      reportIssue(#"Unimplemented: @Dependency(\.paywallID)"#)
      return ""
    }
  }
}

public struct PaywallIDGenerator: Sendable {
  private var generate: @Sendable (Paywall.PaywallType) -> Paywall.ID

  public static func constant(_ id: Paywall.ID) -> Self {
    Self { _ in id }
  }

  public init(_ generate: @escaping @Sendable (Paywall.PaywallType) -> Paywall.ID) {
    self.generate = generate
  }

  public func callAsFunction(_ type: Paywall.PaywallType) -> Paywall.ID {
    self.generate(type)
  }
}
