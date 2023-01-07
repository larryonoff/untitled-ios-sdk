import SwiftUI

extension Label where Title == Text, Icon == Image {
    /// Creates a label with a system icon image and a title generated from a
    /// localized string.
    ///
    /// - Parameters:
    ///    - titleKey: A title generated from a localized string.
    ///    - systemImage: The name of the image resource to lookup.
  public init(_ title: String, symbol: SFSymbol) {
    self.init(title, systemImage: symbol.rawValue)
  }
}
