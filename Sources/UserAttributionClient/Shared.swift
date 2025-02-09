import Foundation

extension Bundle {
  public var appleID: String? {
    infoDictionary?["XAppleID"] as? String
  }

  public var appsFlyerAPIKey: String? {
    infoDictionary?["XAppsFlyerAPIKey"] as? String
  }
}
