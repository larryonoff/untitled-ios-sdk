#if os(iOS)

import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var application: ApplicationClient {
    get { self[ApplicationClient.self] }
    set { self[ApplicationClient.self] = newValue }
  }
}

@DependencyClient
public struct ApplicationClient: Sendable {
  public var isIdleTimerDisabled: @Sendable () async -> Bool = { false }
  public var setIdleTimerDisabled: @Sendable (_ _: Bool) async -> Void
}

#endif
