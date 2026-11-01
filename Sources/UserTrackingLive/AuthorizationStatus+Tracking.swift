import AppTrackingTransparency
import DuckUserTracking
import IssueReporting

extension AuthorizationStatus {
  init(_ status: ATTrackingManager.AuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .restricted:
      self = .restricted
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    @unknown default:
      reportIssue("Unknown ATTrackingManager.AuthorizationStatus: \(status)")
      self = .notDetermined
    }
  }

  var atAuthorizationStatus: ATTrackingManager.AuthorizationStatus {
    switch self {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorized:
      return .authorized
    }
  }
}
