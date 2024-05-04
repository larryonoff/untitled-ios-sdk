public struct ConnectivityInfo {
  public var isConnected: Bool

  public var state: ConnectivityState

  public init(
    isConnected: Bool = false,
    state: ConnectivityState = .loopback
  ) {
    self.isConnected = isConnected
    self.state = state
  }
}

public enum ConnectivityState {
  case cellularWithInternet
  case cellularWithoutInternet
  case disconnected
  case ethernetWithInternet
  case ethernetWithoutInternet
  case loopback
  case otherWithInternet
  case otherWithoutInternet
  case wifiWithInternet
  case wifiWithoutInternet
}

extension ConnectivityInfo: Equatable {}
extension ConnectivityInfo: Hashable {}
extension ConnectivityInfo: Sendable {}

extension ConnectivityState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .cellularWithInternet:
      "Cellular with Internet connectivity"
    case .cellularWithoutInternet:
      "Cellular without Internet connectivity"
    case .disconnected:
      "Disconnected"
    case .ethernetWithInternet:
      "Ethernet with Internet connectivity"
    case .ethernetWithoutInternet:
      "Ethernet without Internet connectivity"
    case .loopback:
      "Loopback"
    case .otherWithInternet:
      "Other with Internet connectivity"
    case .otherWithoutInternet:
      "Other without Internet connectivity"
    case .wifiWithInternet:
      "Wi-Fi with Internet connectivity"
    case .wifiWithoutInternet:
      "Wi-Fi without Internet connectivity"
    }
  }
}

extension ConnectivityState: Equatable {}
extension ConnectivityState: Hashable {}
extension ConnectivityState: Sendable {}
