#if canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))

import UIKit

@available(iOS 13.0, *)
public extension UIApplicationShortcutIcon {
  /// Create an icon using a system symbol image of the given type.
  ///
  /// - Parameter symbol: The `SFSymbol` describing this image.
  convenience init(symbol: SFSymbol) {
    self.init(systemImageName: symbol.rawValue)
  }
}

#endif
