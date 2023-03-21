import FacebookCore
import UIKit

extension FacebookClient {
  public static let live = FacebookClient(
    appDidFinishLaunching: { options in
      _ = ApplicationDelegate.shared.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: options
      )
    },
    appOpenURL: { url, options in
      _ = ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        options: options
      )
    },
    userID: {
      AccessToken.current?.userID
    }
  )
}
