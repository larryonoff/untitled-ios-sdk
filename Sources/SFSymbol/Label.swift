import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
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
