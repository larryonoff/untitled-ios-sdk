import Foundation
import UIKit

extension OpenURL {
  public static let live: Self = {
    OpenURL(
      open: { @MainActor url in
        let app = UIApplication.shared
        return await app.open(url)
      }
    )
  }()
}
