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
            let _authStatus = ATTrackingManager.trackingAuthorizationStatus
            return AuthorizationStatus(_authStatus)
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
                .status: AuthorizationStatus(_authStatus).description
              ]
            )
          )

          return AuthorizationStatus(_authStatus)
        }

        return .authorized
      }
    )
  }
}

private let _authorizationStatus = CurrentValueSubject<AuthorizationStatus, Never>(
  .authorized
)

private func _authStatusDidChange(
  _ status: ATTrackingManager.AuthorizationStatus
) {
  _authorizationStatus.value = .init(status)

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
