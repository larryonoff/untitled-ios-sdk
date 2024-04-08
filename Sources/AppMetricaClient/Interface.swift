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
  public var deviceID: @Sendable () -> String? = { nil }

  public var reset: @Sendable () -> Void
}
