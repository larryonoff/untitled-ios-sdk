import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var userIdentifier: UserIdentifierGenerator {
    get { self[UserIdentifierGeneratorKey.self] }
    set { self[UserIdentifierGeneratorKey.self] = newValue }
  }

  private enum UserIdentifierGeneratorKey: DependencyKey {
    static let liveValue = UserIdentifierGenerator.liveValue
    static let previewValue = UserIdentifierGenerator.noop
    static let testValue = UserIdentifierGenerator.testValue
  }
}

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
