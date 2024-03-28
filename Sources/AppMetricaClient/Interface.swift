import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var appMetrica: AppMetricaClient {
    get { self[AppMetricaClient.self] }
    set { self[AppMetricaClient.self] = newValue }
  }
}

@DependencyClient
public struct AppMetricaClient {
  public var deviceID: @Sendable () async -> String? = { nil }

  public var reset: @Sendable () -> Void
}
