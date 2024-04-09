import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PasteboardClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    changes: unimplemented("\(Self.self).changes"),
    items: unimplemented("\(Self.self).items"),
    probableWebURL: unimplemented("\(Self.self).probableWebURL"),
    setItems: unimplemented("\(Self.self).setItems"),
    setString: unimplemented("\(Self.self).setString")
  )
}

extension PasteboardClient {
  public static let noop = Self(
    changes: { .finished },
    items: { [[:]] },
    probableWebURL: { nil },
    setItems: { _ in },
    setString: { _ in }
  )
}
