import Analytics
import AppTrackingTransparency
import Combine
import ComposableArchitecture
import FacebookCore
import Foundation

extension UserTrackingClient {
  public static func live(
    analytics: Analytics
  ) -> Self {
    UserTrackingClient(
      authorizationStatus: {
        _authorizationStatus.value
      },
      authorizationStatusValues: {
        _authorizationStatus.eraseToEffect()
      },
      initialize: {
        _authStatusDidChange(
          ATTrackingManager.trackingAuthorizationStatus
        )
      },
      isAuthorizationRequestNeeded: {
        _isAuthorizationRequestNeeded()
      },
      requestAuthorization: { dueTime in
        if #available(iOS 14.5, *) {
          guard _isAuthorizationRequestNeeded() else {
            return ATTrackingManager.trackingAuthorizationStatus
          }

          analytics.log(.idfaRequested)

          if dueTime > 0 {
            try? await Task.sleep(nanoseconds: dueTime * 1_00_000_000)
          }

          let _authStatus =
            await ATTrackingManager.requestTrackingAuthorization()

          _authStatusDidChange(_authStatus)

          analytics.log(
            .event(
              eventName: .idfaResult,
              parameters: [
                .status: _authStatus.description
              ]
            )
          )

          return _authStatus
        }

        return .authorized
      }
    )
  }
}

private let _authorizationStatus = CurrentValueSubject<ATTrackingManager.AuthorizationStatus, Never>(
  .authorized
)

private func _authStatusDidChange(
  _ status: ATTrackingManager.AuthorizationStatus
) {
  _authorizationStatus.value = status

  let isAuthorized = status == .authorized
  let fbSettings = FacebookCore.Settings.shared
  fbSettings.isAdvertiserIDCollectionEnabled = isAuthorized
  fbSettings.isAdvertiserTrackingEnabled = isAuthorized
}

private func _isAuthorizationRequestNeeded() -> Bool {
  if #available(iOS 14.5, *) {
    return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
  }
  return false
}
