import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var analytics: AnalyticsClient {
    get { self[AnalyticsClient.self] }
    set { self[AnalyticsClient.self] = newValue }
  }
}

@DependencyClient
public struct AnalyticsClient {
  public var logEvent: @Sendable (
    _ _: EventName,
    _ parameters: [EventParameterName: Any]?
  ) -> Void

  @DependencyEndpoint(method: "set")
  public var setUserProperty: @Sendable (
    _ _ : Any?,
    _ for: UserPropertyName
  ) -> Void

  // MARK: - Extension

  public func log(
    _ eventName: EventName,
    parameters: [EventParameterName: Any]? = nil
  ) {
    self.logEvent(eventName, parameters: parameters)
  }
}
