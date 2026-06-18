import Dependencies
import Foundation
public import Tagged

extension DependencyValues {
  public var userIdentifier: UserIdentifierClient {
    get { self[UserIdentifierClient.self] }
    set { self[UserIdentifierClient.self] = newValue }
  }
}

extension UserIdentifierClient: DependencyKey {}

public enum UserIdentifierTag {}
public typealias UserIdentifier = Tagged<UserIdentifierTag, UUID>

public struct UserIdentifierClient: Sendable {
  /// The user identifier: restores the persisted one, minting and
  /// persisting a new identifier on first access of a fresh install.
  public var identifier: @Sendable () -> UserIdentifier
  /// The identifier that was already persisted when this client was
  /// created — i.e. it survived from a previous install. `nil` on a fresh
  /// install for the whole process lifetime, even after `identifier()`
  /// mints one.
  public var identifierAtLaunch: @Sendable () -> UserIdentifier?
  public var reset: @Sendable () -> Void

  public init(
    identifier: @escaping @Sendable () -> UserIdentifier,
    identifierAtLaunch: @escaping @Sendable () -> UserIdentifier?,
    reset: @escaping @Sendable () -> Void
  ) {
    self.identifier = identifier
    self.identifierAtLaunch = identifierAtLaunch
    self.reset = reset
  }

  public func callAsFunction() -> UserIdentifier {
    self.identifier()
  }
}
