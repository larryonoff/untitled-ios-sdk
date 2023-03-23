import Dependencies

extension DependencyValues {
  public var amplitude: AmplitudeClient {
    get { self[AmplitudeClient.self] }
    set { self[AmplitudeClient.self] = newValue }
  }
}

public struct AmplitudeClient {
  public var initialize: @Sendable () -> Void
  public var deviceID: @Sendable () -> String?
  public var reset: @Sendable () -> Void
}
