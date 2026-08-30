import Dependencies
import Foundation

extension UserIdentifierClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension UserIdentifierClient {
  public static let noop = Self(
    identifier: { .zero },
    identifierAtLaunch: { nil },
    reset: {}
  )
}
