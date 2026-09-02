public enum ConnectivityError: Swift.Error {
  case notConnected
}

extension ConnectivityError: Equatable {}
extension ConnectivityError: Sendable {}
