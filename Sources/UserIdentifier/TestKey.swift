import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserIdentifierClient {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    identifier: unimplemented("\(Self.self).identifier", placeholder: .zero),
    identifierAtLaunch: unimplemented("\(Self.self).identifierAtLaunch", placeholder: nil),
    reset: unimplemented("\(Self.self).reset")
  )
}

extension UserIdentifierClient {
  public static let noop = Self(
    identifier: { .zero },
    identifierAtLaunch: { nil },
    reset: {}
  )
}
