import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var appMetrica: AppMetricaClient {
    get { self[AppMetricaClient.self] }
    set { self[AppMetricaClient.self] = newValue }
  }
}

@DependencyClient
public struct AppMetricaClient: Sendable {
  public enum AttributionSource {
    case appsFlyer
  }

  public var deviceID: @Sendable () -> String? = { nil }
  public var profileID: @Sendable () -> String? = { nil }

  @DependencyEndpoint(method: "report")
  public var reportError: @Sendable (
    _ _: Error
  ) -> Void

  @DependencyEndpoint()
  public var reportExternalAttribution: @Sendable (
    _ _: [AnyHashable: Any],
    _ from: AttributionSource
  ) async throws -> Void

  public var reset: @Sendable () -> Void
}
