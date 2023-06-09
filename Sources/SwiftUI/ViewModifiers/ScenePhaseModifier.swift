import SwiftUI

#if os(macOS)
import AppKit
typealias App = NSApplication
#else
import UIKit
typealias App = UIApplication
#endif

struct ScenePhaseModifier: ViewModifier {
  private let action: (ScenePhase) -> Void

  init(_ action: @escaping (ScenePhase) -> Void) {
    self.action = action
  }

  func body(content: Content) -> some View {
    content
      .onAppear()/// `onReceive` will not work in the Modifier Without `onAppear`
      .onReceive(NotificationCenter.default.publisher(for: App.didBecomeActiveNotification)) { _ in
        action(.active)
      }
      .onReceive(NotificationCenter.default.publisher(for: App.willResignActiveNotification)) { _ in
        action(.inactive)
      }
  }
}

extension View {
  public func onScenePhaseChanged(
    perform action: @escaping (ScenePhase) -> Void
  ) -> some View {
    modifier(ScenePhaseModifier(action))
  }
}
