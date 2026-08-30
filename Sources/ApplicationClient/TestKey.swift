#if os(iOS)

import Dependencies

extension ApplicationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension ApplicationClient {
  public static let noop = Self(
    isIdleTimerDisabled: { true },
    setIdleTimerDisabled: { _ in }
  )
}

#endif
