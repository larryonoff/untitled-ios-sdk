import Dependencies
import DependenciesMacros
import DuckCore

extension DependencyValues {
  public var autoPresentation: AutoPresentationClient {
    get { self[AutoPresentationClient.self] }
    set { self[AutoPresentationClient.self] = newValue }
  }
}

@DependencyClient
public struct AutoPresentationClient: Sendable {
  public var availableFeatures: @Sendable (
  ) -> [AutoPresentation.Feature] = { [] }

  public var isEligibleForPresentation: @Sendable (
    _ _: AutoPresentation.Feature,
    _ request: AutoPresentation.Request
  ) async -> Bool = { _, _ in false }

  public var increment: @Sendable (
    _ _: AutoPresentation.Feature
  ) async -> Void

  @DependencyEndpoint(method: "log")
  public var logEvent: @Sendable (
    _ _: AutoPresentation.Event
  ) async -> Void

  public var reset: @Sendable () async -> Void

  /// The first available feature eligible for `request`.
  @Sendable
  public func featureToPresent(
    _ request: AutoPresentation.Request
  ) async -> AutoPresentation.Feature? {
    for feature in availableFeatures() {
      guard await isEligibleForPresentation(feature, request) else {
        continue
      }
      return feature
    }

    return nil
  }
}
