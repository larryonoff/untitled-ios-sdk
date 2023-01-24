import Dependencies
import Foundation
import Tagged
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

public enum UserIdentifierTag {}
public typealias UserIdentifier = Tagged<UserIdentifierTag, UUID>

public struct UserIdentifierGenerator: Sendable {
  private let generate: @Sendable () -> UserIdentifier

  public var reset: @Sendable () -> Void

  init(
    generate: @escaping @Sendable () -> UserIdentifier,
    reset: @escaping @Sendable () -> Void
  ) {
    self.generate = generate
    self.reset = reset
  }

  public func callAsFunction() -> UserIdentifier {
    self.generate()
  }
}
