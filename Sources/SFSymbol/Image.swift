#if canImport(SwiftUI)

import SwiftUI

extension Image {
  /// Create an image using a system symbol image of the given type.
  ///
  /// - Parameter symbol: The `SFSymbol` describing this image.
  public init(symbol: SFSymbol) {
    self.init(systemName: symbol.rawValue)
  }
}

#endif
