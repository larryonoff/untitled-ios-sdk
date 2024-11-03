import DeviceKit
import SwiftUI

extension EnvironmentValues {
  public var device: Device {
    get { self[DeviceKey.self] }
    set { self[DeviceKey.self] = newValue }
  }

  private struct DeviceKey: EnvironmentKey {
    static var defaultValue: Device { .current }
  }
}
