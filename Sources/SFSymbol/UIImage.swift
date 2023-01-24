#if canImport(UIKit)

import UIKit

extension UIImage {
  /// Create an image using a system symbol image of the given type.
  ///
  /// - Parameters:
  ///   - symbol: The `SFSymbol` describing this image.
  ///   - configuration: The symbol configuration the system applies to the image.
  public convenience init?(
    symbol: SFSymbol,
    withConfiguration configuration: Configuration? = nil
  ) {
    self.init(
      systemName: symbol.rawValue,
      withConfiguration: configuration
    )
  }
}

#endif
