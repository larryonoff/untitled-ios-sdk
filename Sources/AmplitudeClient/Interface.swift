import Dependencies

extension DependencyValues {
  public var amplitude: AmplitudeClient {
    get { self[AmplitudeClient.self] }
    set { self[AmplitudeClient.self] = newValue }
  }
}

public struct AmplitudeClient {
  public var initialize: @Sendable () async -> Void
}
