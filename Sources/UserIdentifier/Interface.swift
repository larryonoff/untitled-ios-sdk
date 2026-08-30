import Dependencies
import DependenciesMacros
import Foundation
public import Tagged

extension DependencyValues {
  public var userIdentifier: UserIdentifierClient {
    get { self[UserIdentifierClient.self] }
    set { self[UserIdentifierClient.self] = newValue }
  }
}

public enum UserIdentifierTag {}
public typealias UserIdentifier = Tagged<UserIdentifierTag, UUID>

extension UserIdentifier {
  static let zero = Self(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
}

@DependencyClient
public struct UserIdentifierClient: Sendable {
  /// The user identifier: restores the persisted one, minting and
  /// persisting a new identifier on first access of a fresh install.
  public var identifier: @Sendable () -> UserIdentifier = { .zero }
  /// The identifier that was already persisted when this client was
  /// created — i.e. it survived from a previous install. `nil` on a fresh
  /// install for the whole process lifetime, even after `identifier()`
  /// mints one.
  public var identifierAtLaunch: @Sendable () -> UserIdentifier?
  public var reset: @Sendable () -> Void

  @Sendable
  public func callAsFunction() -> UserIdentifier {
    self.identifier()
  }
}
