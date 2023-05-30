import Dependencies

extension DependencyValues {
  public var environment: Environment {
    get { self[Environment.self] }
    set { self[Environment.self] = newValue }
  }
}

public enum Environment {
  case production
  case staging
}

extension Environment: Equatable {}

extension Environment: Hashable {}

extension Environment: Sendable {}

extension Environment: TestDependencyKey {
  public static let testValue = Environment.staging
}
