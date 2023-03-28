import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PasteboardClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    changes: unimplemented("\(Self.self).changes"),
    probableWebURL: unimplemented("\(Self.self).probableWebURL"),
    setString: unimplemented("\(Self.self).setString")
  )
}

extension PasteboardClient {
  public static let noop = Self(
    changes: { .finished },
    probableWebURL: { nil },
    setString: { _ in }
  )
}
