import Dependencies
import FacebookCore
import UIKit

extension FacebookClient: DependencyKey {
  public static let liveValue = FacebookClient(
    continueUserActivity: {
      ApplicationDelegate.shared.application(
        UIApplication.shared,
        continue: $0
      )
    },
    didFinishLaunching: { options in
      ApplicationDelegate.shared.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: options
      )
    },
    openURL: { url, options in
      ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        options: options
      )
    },
    anonymousID: {
      AppEvents.shared.anonymousID
    },
    userID: {
      AccessToken.current?.userID
    }
  )
}
