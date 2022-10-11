import Dependencies
import Foundation
import KeychainAccess

extension UserIdentifierGenerator {
  public static let liveValue: Self = {
    let keychain = Keychain.userIdentifier

    return UserIdentifierGenerator(
      generate: {
        if let identifier = keychain.userIdentifier {
          return identifier
        }

        let identifier = UUID()

        keychain.userIdentifier = identifier

        return identifier
      },
      reset: {
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

extension UUID {
  static let zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
