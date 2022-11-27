import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserIdentifierGenerator {
  static var previewValue = Self.noop

  static let testValue = Self(
    generate: unimplemented("\(Self.self).generate", placeholder: .zero),
    reset: unimplemented("\(Self.self).reset")
  )
}

extension UserIdentifierGenerator {
  public static let noop = Self(
    generate: { .zero },
    reset: {}
  )
}
