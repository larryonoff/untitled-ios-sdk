import Foundation

extension Bundle {
  public subscript(_ key: String) -> Any? {
    infoDictionary?[key]
  }

  public func url(forResource name: String?) -> URL? {
    url(forResource: name, withExtension: nil)
  }
}

extension Bundle {
  public var bundleName: String? {
    self["CFBundleName"] as? String
  }

  public var bundleShortVersion: String? {
    self["CFBundleShortVersionString"] as? String
  }

  public var bundleVersion: String? {
    self["CFBundleVersion"] as? String
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
    self["XAppleID"] as? String
  }
}
