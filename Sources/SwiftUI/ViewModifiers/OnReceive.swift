import Combine
import SwiftUI

extension View {
  public func onReceive<Output>(
    _ publisher: (some Publisher<Output, Never>)?,
    perform action: @escaping (Output) -> Void) -> some View
  {
    Group {
      if let publisher {
        self.onReceive(publisher, perform: action)
      } else {
        self
      }
    }
  }
}
