import Combine
import SwiftUI

extension View {
  public func onReceive<P>(
    _ publisher: P?,
    perform action: @escaping (P.Output) -> Void) -> some View
  where P: Publisher, P.Failure == Never
  {
    Group {
      if let publisher = publisher {
        self.onReceive(publisher, perform: action)
      } else {
        self
      }
    }
  }
}
