import Dependencies
import DuckCore

extension DependencyValues {
  public var appEnv: AppEnv {
    get { self[AppEnv.self] }
    set { self[AppEnv.self] = newValue }
  }
}

extension AppEnv: TestDependencyKey {
  public static let testValue = AppEnv.staging
}
