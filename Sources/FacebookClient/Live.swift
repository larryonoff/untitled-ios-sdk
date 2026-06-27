import Dependencies
import FacebookCore
import UIKit

extension FacebookClient: DependencyKey {
  public static let liveValue = FacebookClient(
    continueUserActivity: { userActivity in
      // SAFETY: app lifecycle callbacks are always delivered on the main thread;
      // the captured value is used only within the main-actor body and not shared.
      nonisolated(unsafe) let userActivity = userActivity
      return MainActor.assumeIsolated {
        ApplicationDelegate.shared.application(
          UIApplication.shared,
          continue: userActivity
        )
      }
    },
    didFinishLaunching: { options in
      // SAFETY: app lifecycle callbacks are always delivered on the main thread;
      // the captured value is used only within the main-actor body and not shared.
      nonisolated(unsafe) let options = options
      return MainActor.assumeIsolated {
        ApplicationDelegate.shared.application(
          UIApplication.shared,
          didFinishLaunchingWithOptions: options
        )
      }
    },
    openURL: { url, options in
      // SAFETY: app lifecycle callbacks are always delivered on the main thread;
      // the captured values are used only within the main-actor body and not shared.
      nonisolated(unsafe) let url = url
      nonisolated(unsafe) let options = options
      return MainActor.assumeIsolated {
        ApplicationDelegate.shared.application(
          UIApplication.shared,
          open: url,
          options: options
        )
      }
    },
    anonymousID: {
      AppEvents.shared.anonymousID
    },
    userID: {
      AccessToken.current?.userID
    }
  )
}
