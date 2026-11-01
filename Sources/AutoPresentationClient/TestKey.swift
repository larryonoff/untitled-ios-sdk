import Dependencies

extension AutoPresentationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension AutoPresentationClient {
  public static let noop = Self(
    availableFeatures: { [] },
    isEligibleForPresentation: { _, _ in false },
    requestPresentation: { _ in },
    presentations: { .finished },
    increment: { _ in },
    logEvent: { _ in },
    reset: {}
  )
}
