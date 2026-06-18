import ConcurrencyExtras
import Foundation

extension UserSettingsClient {
  public static func live(
    userDefaults: UserDefaults
  ) -> Self {
    let _defaults = UncheckedSendable(userDefaults)

    return Self(
      boolForKey: { _defaults.value.bool(forKey: $0) },
      dataForKey: { _defaults.value.data(forKey: $0) },
      doubleForKey: { _defaults.value.double(forKey: $0) },
      integerForKey: { _defaults.value.integer(forKey: $0) },
      objectForKey: { _defaults.value.object(forKey: $0) },
      removeValueForKey: { _defaults.value.removeObject(forKey: $0) },
      setBool: { _defaults.value.set($0, forKey: $1) },
      setData: { _defaults.value.set($0, forKey: $1) },
      setDouble: { _defaults.value.set($0, forKey: $1) },
      setInteger: { _defaults.value.set($0, forKey: $1) },
      setObject: { _defaults.value.set($0, forKey: $1) }
    )
  }
}
