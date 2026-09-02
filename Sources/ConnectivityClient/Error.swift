import Foundation

public enum ConnectivityError: Swift.Error {
  case notConnected
}

extension ConnectivityError: Equatable {}

extension ConnectivityError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .notConnected:
      String(localized: .Connectivity.Error.notConnected)
    }
  }
}

extension ConnectivityError: Sendable {}
