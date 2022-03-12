#if canImport(UIKit)

import UIKit

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
extension UIImage {
  /// Create an image using a system symbol image of the given type.
  ///
  /// - Parameter symbol: The `SFSymbol` describing this image.
  public convenience init?(symbol: SFSymbol) {
    self.init(systemName: symbol.rawValue)
  }
}

#endif