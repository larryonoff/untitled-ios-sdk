import ComposableArchitecture
import Dependencies
import DuckCore
import DuckDependencies

extension PersistenceReaderKey where Self == PersistenceKeyDefault<AppEnvPersistenceKey> {
  public static var appEnv: Self {
    PersistenceKeyDefault(AppEnvPersistenceKey(), .production)
  }
}

public struct AppEnvPersistenceKey: PersistenceReaderKey, Sendable {
  @Dependency(\.appEnv) var appEnv

  public init() {}

  public var id: AnyHashable {
    AppEnvKeyID()
  }

  public func load(initialValue: AppEnv?) -> AppEnv? {
    appEnv
  }
}

private struct AppEnvKeyID: Hashable {}
