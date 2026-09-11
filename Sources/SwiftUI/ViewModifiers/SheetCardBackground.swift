#if canImport(UIKit)
  import UIKit
#endif

import SwiftUI

extension View {
  /// The sheet surface for the SDK's asks: on iOS 26 the solid fill is dropped
  /// so the system Liquid Glass material shows; earlier systems keep an opaque
  /// card with the sheet's own corners.
  @ViewBuilder
  public func sheetCardBackground() -> some View {
    if #available(iOS 26, macOS 26, *) {
      self
    } else {
      #if os(iOS)
        self
          .presentationBackground(Color(uiColor: .secondarySystemBackground))
          .presentationCornerRadius(40)
      #else
        self
      #endif
    }
  }
}
