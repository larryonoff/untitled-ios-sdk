import Dependencies

public enum Environment {
  case production
  case staging
}

extension Environment: Equatable {}

extension Environment: Hashable {}

extension Environment: Sendable {}
