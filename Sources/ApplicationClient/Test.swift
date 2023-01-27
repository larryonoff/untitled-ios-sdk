#if os(iOS)

import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension ApplicationClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    isIdleTimerDisabled: unimplemented("\(Self.self).isIdleTimerDisabled", placeholder: true),
    setIdleTimerDisabled: unimplemented("\(Self.self).setIdleTimerDisabled")
  )
}

extension ApplicationClient {
  public static let noop = Self(
    isIdleTimerDisabled: { true },
    setIdleTimerDisabled: { _ in }
  )
}

#endif
