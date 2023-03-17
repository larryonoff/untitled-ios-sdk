import FirebaseRemoteConfig

extension RemoteConfigFetchStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .noFetchYet:
      return "noFetchYet"
    case .success:
      return "success"
    case .failure:
      return "failure"
    case .throttled:
      return "throttled"
    @unknown default:
      return
        "RemoteConfigFetchStatus.(@unknown default, rawValue: \(self.rawValue))"
    }
  }
}

extension RemoteConfigFetchAndActivateStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .successFetchedFromRemote:
      return "successFetchedFromRemote"
    case .successUsingPreFetchedData:
      return "successUsingPreFetchedData"
    case .error:
      return "error"
    @unknown default:
      return
        "RemoteConfigFetchAndActivateStatus.(@unknown default, rawValue: \(self.rawValue))"
    }
  }
}
