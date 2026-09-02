#if canImport(UIKit)

import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

@Reducer
public struct ShareSheet<Data: RandomAccessCollection & Sendable> {
  public enum Action {
    public enum Delegate {
      case completed(Result<Data, any Error>)
      case cancelled
    }

    case delegate(Delegate)
  }

  @ObservableState
  public struct State {
    public let data: Data

    public init(
      data: Data
    ) {
      self.data = data
    }
  }

  public init() {}
}

extension ShareSheet.State where Data == [URL] {
  /// Shares a single file `url`. Convenience over wrapping it in an array.
  public init(url: URL) {
    self.init(data: [url])
  }
}

extension ShareSheet.State where Data == [String] {
  /// Shares a single text `item`. Convenience over wrapping it in an array.
  public init(item: String) {
    self.init(data: [item])
  }
}

extension View {
  /// Presents a share sheet when a piece of optional state held in a store becomes non-`nil`.
  public func shareSheet<Data: RandomAccessCollection & Sendable>(
    _ item: Binding<StoreOf<ShareSheet<Data>>?>
  ) -> some View {
    // The store is captured while the state is still non-`nil`. It must not be
    // re-read inside the callbacks: `isPresented` nils the state out before they
    // run, so reading it there would drop the delegate action entirely.
    let store = item.wrappedValue

    return self.shareSheet(
      isPresented: Binding(item),
      data: store?.data,
      onCompletion: { result in
        store?.send(.delegate(.completed(result)))
      },
      onCancellation: {
        store?.send(.delegate(.cancelled))
      }
    )
  }
}

#endif
