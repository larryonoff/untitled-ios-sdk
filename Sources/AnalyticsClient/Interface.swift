import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var analytics: AnalyticsClient {
    get { self[AnalyticsClient.self] }
    set { self[AnalyticsClient.self] = newValue }
  }
}

@DependencyClient
public struct AnalyticsClient: Sendable {
  public var logEvent: @Sendable (
    _ _: EventName,
    _ parameters: [EventParameterName: any Sendable]?
  ) -> Void

  @DependencyEndpoint(method: "set")
  public var setUserProperty: @Sendable (
    _ _ : (any Sendable)?,
    _ for: UserPropertyName
  ) -> Void

  // MARK: - Extension

  @Sendable
  public func log(
    _ eventName: EventName,
    parameters: [EventParameterName: any Sendable]? = nil
  ) {
    self.logEvent(eventName, parameters: parameters)
  }
}
