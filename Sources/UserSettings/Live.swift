import Foundation

extension UserSettingsClient {
  public static func live(
    userDefaults: UserDefaults
  ) -> Self {
    Self(
      boolForKey: userDefaults.bool(forKey:),
      dataForKey: userDefaults.data(forKey:),
      doubleForKey: userDefaults.double(forKey:),
      integerForKey: userDefaults.integer(forKey:),
      removeValueForKey: { userDefaults.removeObject(forKey: $0) },
      setBool: { userDefaults.set($0, forKey: $1) },
      setData: { userDefaults.set($0, forKey: $1) },
      setDouble: { userDefaults.set($0, forKey: $1) },
      setInteger: { userDefaults.set($0, forKey: $1) }
    )
  }
}
