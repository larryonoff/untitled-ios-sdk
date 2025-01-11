import DuckCore
import DuckDependencies
import Sharing

extension SharedReaderKey where Self == AppEnvKey.Default {
  public static var appEnv: Self {
    Self[AppEnvKey(), default: .production]
  }
}

public struct AppEnvKey: SharedReaderKey, Sendable {
  @Dependency(\.appEnv) var appEnv

  public init() {}

  public typealias Value = AppEnv

  public var id: AppEnvKeyID {
    AppEnvKeyID()
  }

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resume(with: .success(appEnv))
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    SharedSubscription {}
  }
}

public struct AppEnvKeyID: Hashable {}
