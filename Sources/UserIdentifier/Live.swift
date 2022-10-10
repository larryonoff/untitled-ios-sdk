import Foundation
import KeychainAccess

extension UserIdentifierGenerator {
  public static let live: Self = {
    return UserIdentifierGenerator(
      generate: {
        let keychain = Keychain.userIdentifier

        if
          let identifier = try? keychain
            .get(.userIdentifierKey)
            .flatMap(UUID.init(uuidString:))
        {
          return identifier
        }

        let identifier = UUID()

        try? keychain.set(
          identifier.uuidString,
          key: .userIdentifierKey
        )

        return identifier
      },
      reset: {
        try? Keychain.userIdentifier.set(
          UUID().uuidString,
          key: .userIdentifierKey
        )
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
}
