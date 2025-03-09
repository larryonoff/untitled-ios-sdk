import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var userAttribution: UserAttributionClient {
    get { self[UserAttributionClient.self] }
    set { self[UserAttributionClient.self] = newValue }
  }
}

@DependencyClient
public struct UserAttributionClient: Sendable {
  public struct Attribution: @unchecked Sendable {
    private let _dictionary: [AnyHashable: Any]?

    public var dictionary: [AnyHashable: Any]? { _dictionary }

    public init(
      _ dictionary: [AnyHashable: Any]?
    ) {
      self._dictionary = dictionary
    }
  }

  public struct Configuration: Sendable {
    public struct UserTracking: Sendable {
      public var authorizationWaitTimeoutInterval: UInt?

      public init(
        authorizationWaitTimeoutInterval: UInt? = 120
      ) {
        self.authorizationWaitTimeoutInterval = authorizationWaitTimeoutInterval
      }
    }

    public var userTracking: UserTracking?

    public init(
      userTracking: UserTracking? = nil
    ) {
      self.userTracking = userTracking
    }
  }

  public enum DelegateEvent: Sendable {
    case onAttributionChanged(Attribution)
  }

  public var initialize: @Sendable (Configuration) -> Void

  public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }

  public var uid: @Sendable () async -> String? = { nil }

  public var reset: @Sendable () -> Void
}
