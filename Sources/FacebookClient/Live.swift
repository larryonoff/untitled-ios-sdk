import FacebookCore
import UIKit

extension FacebookClient {
  public static let live = FacebookClient(
    appDidFinishLaunching: { options in
      await MainActor.run {
        _ = ApplicationDelegate.shared
          .application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: options
          )
      }
    },
    appOpenURL: { url, options in
      await MainActor.run {
        _ = ApplicationDelegate.shared
          .application(
            UIApplication.shared,
            open: url,
            options: options
          )
      }
    }
  )
}
