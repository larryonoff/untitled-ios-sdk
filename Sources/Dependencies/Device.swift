@_exported import DeviceKit
import Dependencies
import Sharing

extension DependencyValues {
  public var device: Device {
    get { self[DeviceKey.self] }
    set { self[DeviceKey.self] = newValue }
  }

  private enum DeviceKey: DependencyKey {
    static let liveValue = Device.current
  }
}

// SAFETY: `Device` is an immutable value type; DeviceKit doesn't annotate it
// `Sendable`. Treated as such here so it can flow through dependencies/sharing.
extension Device: @retroactive @unchecked Sendable {}

extension SharedReaderKey where Self == InMemoryKey<Device>.Default {
  public static var bundle: Self {
    Self[.inMemory("device"), default: .current]
  }
}
