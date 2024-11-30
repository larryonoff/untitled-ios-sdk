import Dependencies
import DuckCore
import DuckPurchases

extension DependencyValues {
  public var paywallType: PaywallTypeGenerator {
    get { self[PaywallTypeGeneratorKey.self] }
    set { self[PaywallTypeGeneratorKey.self] = newValue }
  }

  private enum PaywallTypeGeneratorKey: DependencyKey {
    static let liveValue = PaywallTypeGenerator { _ in "" }
    static let testValue = PaywallTypeGenerator { _ in
      reportIssue(#"Unimplemented: @Dependency(\.paywallType)"#)
      return ""
    }
  }
}

public struct PaywallTypeGenerator: Sendable {
  private var generate: @Sendable (Placement?) -> Paywall.PaywallType

  public static func constant(_ type: Paywall.PaywallType) -> Self {
    Self { _ in type }
  }

  public init(_ generate: @escaping @Sendable (Placement?) -> Paywall.PaywallType) {
    self.generate = generate
  }

  public func callAsFunction(_ placement: Placement?) -> Paywall.PaywallType {
    self.generate(placement)
  }
}
