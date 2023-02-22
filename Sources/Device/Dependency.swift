import DeviceKit
import Dependencies

extension DependencyValues {
  public var device: Device {
    get { self[DeviceKey.self] }
    set { self[DeviceKey.self] = newValue }
  }

  private enum DeviceKey: DependencyKey {
    static let liveValue = Device.current
  }
}
