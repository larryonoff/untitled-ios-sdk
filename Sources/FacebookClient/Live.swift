import FacebookCore
import UIKit

extension FacebookClient {
  public static let live = FacebookClient(
    appDidFinishLaunching: { @MainActor options in
      _ = ApplicationDelegate.shared
        .application(
          UIApplication.shared,
          didFinishLaunchingWithOptions: options
        )
    },
    appOpenURL: { @MainActor url, options in
      _ = ApplicationDelegate.shared
        .application(
          UIApplication.shared,
          open: url,
          options: options
        )
    }
  )
}
