import Combine
import Connectivity
import Foundation

extension ConnectivityClient {
  public static func live(
    connectivityURLs: [URL] = []
  ) -> Self {
    Self(
      connectivityInfo: {
        let connectivity = Connectivity(
          connectivityURLs: connectivityURLs
        )

        return await withTaskCancellationHandler {
          await withCheckedContinuation { continuation in
            connectivity.checkConnectivity {
              continuation.resume(returning: .init($0))
            }
          }
        } onCancel: {
          connectivity.stopNotifier()
        }
      },
      updates: {
        AsyncStream { continuation in
          let connectivity = Connectivity(
            connectivityURLs: connectivityURLs
          )

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

private extension Connectivity {
  convenience init(connectivityURLs: [URL]) {
    self.init()

    self.framework = .network

    self.pollingInterval = 30.0
    self.isPollingEnabled = true

    self.successThreshold = Connectivity.Percentage(50.0)

    self.connectivityURLs
      .append(contentsOf: connectivityURLs)
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
