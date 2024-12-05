import Dependencies
import Foundation
import DuckRemoteSettingsClient
import Sharing

extension SharedReaderKey {
  /// Creates a persistence key that can read a boolean from remote settings.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Bool> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a integer from remote settings.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Int> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a double from remote settings.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Double> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a string from remote settings.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<String> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a data from remote settings.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Data> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a integer from remote settings, transforming
  /// that to a `RawRepresentable` data type.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting<Value: RawRepresentable<Int>>(_ key: String) -> Self
  where Self == RemoteSettingKey<Value> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read a string from remote settings, transforming
  /// that to a `RawRepresentable` data type.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting<Value: RawRepresentable<String>>(_ key: String) -> Self
  where Self == RemoteSettingKey<Value> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional boolean from remote settings, transforming
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Bool?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional integer from remote settings, transforming
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Int?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional double from remote settings, transforming
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Double?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional string from remote settings, transforming
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<String?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional data from remote settings, transforming
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting(_ key: String) -> Self
  where Self == RemoteSettingKey<Data?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional integer from remote settings,
  /// transforming that to a `RawRepresentable` data type.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting<Value: RawRepresentable<Int>>(_ key: String) -> Self
  where Self == RemoteSettingKey<Value?> {
    RemoteSettingKey(key)
  }

  /// Creates a persistence key that can read an optional string from remote settings,
  /// transforming that to a `RawRepresentable` data type.
  ///
  /// - Parameter key: The key to read the value from the remote setting.
  /// - Returns: A remote settings persistence key.
  public static func remoteSetting<Value: RawRepresentable<String>>(_ key: String) -> Self
  where Self == RemoteSettingKey<Value?> {
    RemoteSettingKey(key)
  }
}

/// A type defining a remote settings persistence strategy.
///
public struct RemoteSettingKey<Value: Sendable>: SharedReaderKey {
  private let lookup: any Lookup<Value>
  private let key: String
  private let store: RemoteSettingsClient

  public var id: RemoteSettingKeyID {
    RemoteSettingKeyID(key: key)
  }

  public init(_ key: String) where Value == Bool {
    @Dependency(\.remoteSettings) var store
    self.lookup = BoolLookup()
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Int {
    @Dependency(\.remoteSettings) var store
    self.lookup = IntLookup()
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Double {
    @Dependency(\.remoteSettings) var store
    self.lookup = DoubleLookup()
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == String {
    @Dependency(\.remoteSettings) var store
    self.lookup = StringLookup()
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Data {
    @Dependency(\.remoteSettings) var store
    self.lookup = DataLookup()
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value: RawRepresentable<Int> {
    @Dependency(\.remoteSettings) var store
    self.lookup = RawRepresentableLookup(base: IntLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value: RawRepresentable<String> {
    @Dependency(\.remoteSettings) var store
    self.lookup = RawRepresentableLookup(base: StringLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Bool? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: BoolLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Int? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: IntLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Double? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: DoubleLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == String? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: StringLookup())
    self.key = key
    self.store = store
  }

  public init(_ key: String) where Value == Data? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: DataLookup())
    self.key = key
    self.store = store
  }

  public init<R: RawRepresentable<Int>>(_ key: String) where Value == R? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: RawRepresentableLookup(base: IntLookup()))
    self.key = key
    self.store = store
  }

  public init<R: RawRepresentable<String>>(_ key: String) where Value == R? {
    @Dependency(\.remoteSettings) var store
    self.lookup = OptionalLookup(base: RawRepresentableLookup(base: StringLookup()))
    self.key = key
    self.store = store
  }

  public func load(initialValue: Value?) -> Value? {
    self.lookup.loadValue(from: self.store, at: self.key, default: initialValue)
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (_ newValue: Value?) -> Void
  ) -> SharedSubscription {
    @Dependency(\.remoteSettings) var store

    let task = Task {
      let value = load(initialValue: initialValue)
      receiveValue(value)
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct RemoteSettingKeyID: Hashable {
  let key: String
}

private protocol Lookup<Value> {
  associatedtype Value
  func loadValue(from store: RemoteSettingsClient, at key: String, default defaultValue: Value?) -> Value?
}

private struct BoolLookup: Lookup {
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Bool?
  ) -> Bool? {
    store.boolForKey(key) ?? defaultValue
  }
}

private struct DataLookup: Lookup {
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Data?
  ) -> Data? {
    store.dataForKey(key) ?? defaultValue
  }
}

private struct DoubleLookup: Lookup {
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Double?
  ) -> Double? {
    store.doubleForKey(key) ?? defaultValue
  }
}

private struct IntLookup: Lookup {
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Int?
  ) -> Int? {
    store.integerForKey(key) ?? defaultValue
  }
}

private struct StringLookup: Lookup {
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: String?
  ) -> String? {
    store.stringForKey(key) ?? defaultValue
  }
}

private struct RawRepresentableLookup<Value: RawRepresentable, Base: Lookup>: Lookup
where Value.RawValue == Base.Value {
  let base: Base
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Value?
  ) -> Value? {
    base.loadValue(from: store, at: key, default: defaultValue?.rawValue)
      .flatMap(Value.init(rawValue:))
      ?? defaultValue
  }
}

private struct OptionalLookup<Base: Lookup>: Lookup {
  let base: Base
  func loadValue(
    from store: RemoteSettingsClient, at key: String, default defaultValue: Base.Value??
  ) -> Base.Value?? {
    base.loadValue(from: store, at: key, default: defaultValue ?? nil)
  }
}
