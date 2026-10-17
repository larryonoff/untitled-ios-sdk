#if os(iOS)

import DuckUIKit
import Sharing
import UIKit

extension SharedReaderKey where Self == InterfaceOrientationKey.Default {
  /// A shared, read-only view of the interface orientation of the app's active window scene.
  ///
  /// ```swift
  /// @SharedReader(.interfaceOrientation) var interfaceOrientation
  /// ```
  public static var interfaceOrientation: Self {
    Self[InterfaceOrientationKey(), default: .unknown]
  }
}

/// Observes `UIWindowScene.effectiveGeometry.interfaceOrientation` of the active window scene,
/// following whichever scene activates last.
public struct InterfaceOrientationKey: SharedReaderKey {
  public typealias Value = UIInterfaceOrientation

  public var id: InterfaceOrientationKeyID {
    InterfaceOrientationKeyID()
  }

  public init() {}

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    Task { @MainActor in
      continuation.resume(
        returning: UIApplication.shared.activeScene?.effectiveGeometry.interfaceOrientation ?? .unknown
      )
    }
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    let task = Task { @MainActor in
      var observation: NSKeyValueObservation?

      for await scene in UIApplication.shared.windowSceneActivations {
        // UIKit changes the geometry on the main thread, and `.initial` reports synchronously here.
        observation = scene.observe(\.effectiveGeometry, options: [.initial, .old, .new]) { _, change in
          guard
            let orientation = change.newValue?.interfaceOrientation,
            orientation != change.oldValue?.interfaceOrientation
          else { return }
          subscriber.yield(orientation)
        }
      }

      observation?.invalidate()
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct InterfaceOrientationKeyID: Hashable {}

@MainActor
extension UIApplication {
  /// The active window scene, then every window scene as it activates.
  var windowSceneActivations: AsyncStream<UIWindowScene> {
    let (stream, continuation) = AsyncStream.makeStream(of: UIWindowScene.self)
    if let activeScene {
      continuation.yield(activeScene)
    }

    let task = Task { @MainActor in
      let notifications = NotificationCenter.default.notifications(named: UIScene.didActivateNotification)
      for await notification in notifications {
        guard let scene = notification.object as? UIWindowScene else { continue }
        continuation.yield(scene)
      }
      continuation.finish()
    }
    continuation.onTermination = { _ in task.cancel() }

    return stream
  }
}

#endif
