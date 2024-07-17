import Dependencies

extension DependencyValues {
  public var appEnv: AppEnv {
    get { self[AppEnv.self] }
    set { self[AppEnv.self] = newValue }
  }
}

public enum AppEnv {
  case production
  case staging
}

extension AppEnv: Equatable {}
extension AppEnv: Hashable {}
extension AppEnv: Sendable {}

extension AppEnv: TestDependencyKey {
  public static let testValue = AppEnv.staging
}
