import Dependencies
import Foundation
import KeychainAccess

extension UserIdentifierGenerator {
  public static let liveValue: Self = {
    let keychain = Keychain.userIdentifier
    let lock = NSRecursiveLock()

    return UserIdentifierGenerator(
      generate: {
        lock.lock(); defer { lock.unlock() }

        if let identifier = keychain.userIdentifier {
          return .init(identifier)
        }

        let identifier = UUID()

        keychain.userIdentifier = identifier

        return .init(identifier)
      },
      reset: {
        lock.lock(); defer { lock.unlock() }

        keychain.userIdentifier = UUID()
      }
    )
  }()
}

private extension String {
  static let userIdentifierKey = "user-identifier"
}

private extension Keychain {
  static let userIdentifier: Keychain = {
    let service = [
      Bundle.main.bundleIdentifier,
      "user-identifier"
    ]
    .compactMap { $0 }
    .joined(separator: ".")

    return Keychain(service: service)
  }()

  var userIdentifier: UUID? {
    get {
      self[string: .userIdentifierKey]
        .flatMap(UUID.init(uuidString:))
    }
    set {
      self[string: .userIdentifierKey] = newValue?.uuidString
    }
  }
}

extension UserIdentifier {
  static let zero = UserIdentifier(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
}
