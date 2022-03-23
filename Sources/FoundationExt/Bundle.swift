import Foundation

extension Bundle {
  public subscript(_ key: String) -> Any? {
    infoDictionary?[key]
  }
}

extension Bundle {
  public var adaptyAPIKey: String? {
    self["XAdaptyAPIKey"] as? String
  }

  public var amplitudeAPIKey: String? {
    self["XAmplitudeAPIKey"] as? String
  }

  public var appsFlyerAPIKey: String? {
    self["XAppsFlyerAPIKey"] as? String
  }

  public var appleID: String? {
    self["X_APPLE_ID"] as? String
  }
}
