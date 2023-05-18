public struct ConnectivityInfo {
  public var isConnected: Bool

  public var state: ConnectivityState
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
      return "Cellular with Internet connectivity"
    case .cellularWithoutInternet:
      return "Cellular without Internet connectivity"
    case .disconnected:
      return "Disconnected"
    case .ethernetWithInternet:
      return "Ethernet with Internet connectivity"
    case .ethernetWithoutInternet:
      return "Ethernet without Internet connectivity"
    case .loopback:
      return "Loopback"
    case .otherWithInternet:
      return "Other with Internet connectivity"
    case .otherWithoutInternet:
      return "Other without Internet connectivity"
    case .wifiWithInternet:
      return "Wi-Fi with Internet connectivity"
    case .wifiWithoutInternet:
      return "Wi-Fi without Internet connectivity"
    }
  }
}

extension ConnectivityState: Equatable {}

extension ConnectivityState: Hashable {}

extension ConnectivityState: Sendable {}
