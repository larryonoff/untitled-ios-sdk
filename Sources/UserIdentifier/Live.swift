import Dependencies
import DuckFoundation
import DuckLogging
import Foundation
import KeychainAccess
import Tagged

extension UserIdentifierClient {
  public static let liveValue: Self = {
    let impl = UserIdentifierImpl()

    return UserIdentifierClient(
      identifier: {
        UserIdentifier(impl.identifier)
      },
      identifierAtLaunch: {
        impl.identifierAtLaunch.map { UserIdentifier($0) }
      },
      reset: {
        impl.reset()
      }
    )
  }()
}

private final class UserIdentifierImpl: Sendable {
  private struct State {
    let keychain: Keychain
    let keychainKey: String
    // The keychain item has no writers besides reset(), so once read the
    // identifier is cached for the lifetime of the process; a nil cache
    // means the launch read found nothing and identifier() re-reads
    // before minting.
    var cachedIdentifier: UUID?

    var persistedIdentifier: UUID? {
      get {
        keychain[string: keychainKey]
          .flatMap(UUID.init(uuidString:))
      }
      nonmutating set {
        keychain[string: keychainKey] = newValue?.uuidString
      }
    }
  }

  /// The identifier persisted before any `identifier()` call: one present
  /// here survived app deletion, as opposed to one minted by this install.
  let identifierAtLaunch: UUID?

  private let state: Mutex<State>

  init() {
    let keychainKey = "user-identifier"
    let keychainService = [
      Bundle.main.bundleIdentifier,
      "user-identifier"
    ]
    .compactMap { $0 }
    .joined(separator: ".")

    var state = State(
      keychain: Keychain(service: keychainService),
      keychainKey: keychainKey,
      cachedIdentifier: nil
    )

    let identifierAtLaunch = state.persistedIdentifier
    state.cachedIdentifier = identifierAtLaunch

    if let identifierAtLaunch {
      logger.info(
        """
        identifier.restore success | \
        identifier: \(identifierAtLaunch.uuidString, privacy: .public)
        """
      )
    }

    self.identifierAtLaunch = identifierAtLaunch
    self.state = Mutex(state)
  }

  var identifier: UUID {
    state.withLock { state in
      if let identifier = state.cachedIdentifier {
        return identifier
      }

      if let identifier = state.persistedIdentifier {
        logger.info(
          """
          identifier.restore success | \
          identifier: \(identifier.uuidString, privacy: .public)
          """
        )

        state.cachedIdentifier = identifier
        return identifier
      }

      let identifier = UUID()
      logger.info(
        """
        identifier.generate success | \
        identifier: \(identifier.uuidString, privacy: .public)
        """
      )

      state.persistedIdentifier = identifier
      state.cachedIdentifier = identifier
      return identifier
    }
  }

  func reset() {
    state.withLock { state in
      let oldIdentifier = state.cachedIdentifier ?? state.persistedIdentifier
      let newIdentifier = UUID()

      logger.info(
        """
        identifier.reset success | \
        old_identifier: \(oldIdentifier?.uuidString ?? "none", privacy: .public) \
        new_identifier: \(newIdentifier.uuidString, privacy: .public)
        """
      )

      state.persistedIdentifier = newIdentifier
      state.cachedIdentifier = newIdentifier
    }
  }
}

extension UserIdentifier {
  static let zero = Self(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
}
