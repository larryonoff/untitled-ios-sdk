import FacebookCore
import UIKit

extension FacebookClient {
  public static let live = FacebookClient(
    appDidFinishLaunching: { options in
      ApplicationDelegate.shared
        .application(
          UIApplication.shared,
          didFinishLaunchingWithOptions: options
        )
    },
    appOpenURL: { url, sourceApplication in
      ApplicationDelegate.shared
        .application(
          UIApplication.shared,
          open: url,
          sourceApplication: sourceApplication,
          annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
  )
}
