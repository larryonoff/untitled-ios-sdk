#if os(iOS)

import Dependencies

extension DependencyValues {
  public var application: ApplicationClient {
    get { self[ApplicationClient.self] }
    set { self[ApplicationClient.self] = newValue }
  }
}

public struct ApplicationClient {
  public var isIdleTimerDisabled: @Sendable () async -> Bool
  public var setIdleTimerDisabled: @Sendable (Bool) async -> Void
}

#endif
