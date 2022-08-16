import Foundation

public struct UserSettingsClient {
  public var boolForKey: (String) -> Bool
  public var dataForKey: (String) -> Data?
  public var doubleForKey: (String) -> Double
  public var integerForKey: (String) -> Int
  public var remove: (String) async -> Void
  public var setBool: (Bool, String) async -> Void
  public var setData: (Data?, String) async -> Void
  public var setDouble: (Double, String) async -> Void
  public var setInteger: (Int, String) async -> Void
}
