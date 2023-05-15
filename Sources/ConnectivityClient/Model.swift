public struct ConnectivityInfo {
  public var isConnected: Bool
}

extension ConnectivityInfo: Equatable {}

extension ConnectivityInfo: Hashable {}

extension ConnectivityInfo: Sendable {}
