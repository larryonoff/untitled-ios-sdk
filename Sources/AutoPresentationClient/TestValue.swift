import Dependencies

extension AutoPresentationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension AutoPresentationClient {
  public static let noop = Self(
    availableFeatures: { [] },
    isEligibleForPresentation: { _, _, _, _ in false },
    increment: { _ in },
    logEvent: { _ in },
    reset: {}
  )
}
