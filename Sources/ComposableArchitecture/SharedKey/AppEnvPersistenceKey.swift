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

  public var id: AppEnvKeyID {
    AppEnvKeyID()
  }

  public func load(initialValue: AppEnv?) -> AppEnv? {
    appEnv
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (Value?) -> Void
  ) -> SharedSubscription {
    SharedSubscription {}
  }
}

public struct AppEnvKeyID: Hashable {}
