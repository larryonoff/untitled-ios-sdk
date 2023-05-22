import Combine
import Connectivity
import Foundation

extension ConnectivityClient {
  public static func live(
    connectivityURLs: [URL]
  ) -> Self {
    Self(
      updates: {
        AsyncStream { continuation in
          let connectivity = Connectivity()

          connectivity.pollingInterval = 30.0
          connectivity.isPollingEnabled = true

          connectivity.successThreshold = Connectivity.Percentage(50.0)

          connectivity.connectivityURLs
            .append(contentsOf: connectivityURLs)
          connectivity.framework = .network

          connectivity.whenConnected = {
            continuation.yield(.init($0))
          }

          connectivity.whenDisconnected = {
            continuation.yield(.init($0))
          }

          continuation.onTermination = { _ in
            connectivity.stopNotifier()
          }

          connectivity.startNotifier()
        }
      }
    )
  }
}

extension ConnectivityInfo {
  init(_ connectivity: Connectivity) {
    self.isConnected = connectivity.isConnected
    self.state = .init(connectivity.status)
  }
}

extension ConnectivityState {
  init(_ status: Connectivity.Status) {
    switch status {
    case .connected:
      self = .loopback
    case .connectedViaCellular:
      self = .cellularWithInternet
    case .connectedViaCellularWithoutInternet:
      self = .cellularWithoutInternet
    case .connectedViaEthernet:
      self = .ethernetWithInternet
    case .connectedViaEthernetWithoutInternet:
      self = .ethernetWithoutInternet
    case .connectedViaWiFi:
      self = .wifiWithInternet
    case .connectedViaWiFiWithoutInternet:
      self = .wifiWithoutInternet
    case .determining:
      self = .loopback
    case .notConnected:
      self = .disconnected
    }
  }
}
