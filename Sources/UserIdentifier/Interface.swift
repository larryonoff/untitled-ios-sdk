import Foundation

public struct UserIdentifierGenerator {
  private let generate: @Sendable () -> UUID

  public var reset: @Sendable () -> Void

  public init(
    generate: @escaping @Sendable () -> UUID,
    reset: @escaping @Sendable () -> Void
  ) {
    self.generate = generate
    self.reset = reset
  }

  public func callAsFunction() -> UUID {
    self.generate()
  }
}
