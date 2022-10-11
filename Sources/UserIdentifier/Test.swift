import Dependencies
import Foundation
import XCTestDynamicOverlay

extension UserIdentifierGenerator {
  static var previewValue = Self.noop

  static let testValue = Self(
    generate: XCTUnimplemented("\(Self.self).generate", placeholder: .zero),
    reset: XCTUnimplemented("\(Self.self).reset")
  )
}

extension UserIdentifierGenerator {
  public static let noop = Self(
    generate: { .zero },
    reset: {}
  )
}
