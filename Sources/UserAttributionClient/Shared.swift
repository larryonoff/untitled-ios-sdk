import Foundation

extension Bundle {
  public var adjustAppToken: String? {
    infoDictionary?["XAdjustAppToken"] as? String
  }

  public var appleID: String? {
    infoDictionary?["XAppleID"] as? String
  }

  public var appsFlyerAPIKey: String? {
    infoDictionary?["XAppsFlyerAPIKey"] as? String
  }
}
