import UIKit

extension PasteboardClient {
  public static let live: Self = {
    .init(
      setString: { string in
        let pasteboard = UIPasteboard.general
        pasteboard.string = string
      }
    )
  }()
}
