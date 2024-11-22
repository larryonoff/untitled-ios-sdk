public enum AppEnv {
  case production
  case staging
}

extension AppEnv: Equatable {}
extension AppEnv: Hashable {}
extension AppEnv: Sendable {}
