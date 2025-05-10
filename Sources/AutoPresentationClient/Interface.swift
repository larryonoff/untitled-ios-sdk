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
    _ event: AutoPresentation.Event?,
    _ placement: Placement?,
    _ userInfo: AutoPresentation.UserInfo?
  ) async -> Bool = { _, _, _, _ in false }

  public var increment: @Sendable (
    _ _: AutoPresentation.Feature
  ) async -> Void

  @DependencyEndpoint(method: "log")
  public var logEvent: @Sendable (
    _ _: AutoPresentation.Event
  ) async -> Void

  public var reset: @Sendable () async -> Void

  public func featureToPresent(
    _ event: AutoPresentation.Event?,
    _ placement: Placement?,
    _ userInfo: AutoPresentation.UserInfo?
  ) async -> AutoPresentation.Feature? {
    for feature in availableFeatures() {
      guard await isEligibleForPresentation(feature, event, placement, userInfo) else {
        continue
      }
      return feature
    }

    return nil
  }
}
