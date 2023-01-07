#if canImport(UIKit)

import UIKit

extension UIImage {
  /// Create an image using a system symbol image of the given type.
  ///
  /// - Parameter symbol: The `SFSymbol` describing this image.
  public convenience init?(symbol: SFSymbol) {
    self.init(systemName: symbol.rawValue)
  }
}

#endif
