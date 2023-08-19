import Dependencies

extension DependencyValues {
  public var appMetrica: AppMetricaClient {
    get { self[AppMetricaClient.self] }
    set { self[AppMetricaClient.self] = newValue }
  }
}

public struct AppMetricaClient {
  public var deviceID: @Sendable () async -> String?
  public var reset: @Sendable () -> Void
}
