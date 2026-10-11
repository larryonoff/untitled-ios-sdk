#if os(iOS)

import DuckUIKit
import Sharing
import UIKit

/// How far a foldable device is open, after `UIHinge.Status`.
public enum HingeStatus: Hashable, Sendable {
  /// Not reported yet, or a status the system can't tell.
  case unknown
  case closed
  case partiallyOpen
  case fullyOpen
}

extension SharedReaderKey where Self == HingeStatusKey.Default {
  /// A shared, read-only view of the device's hinge: `nil` for a device without one — and before
  /// iOS 27.1, which predates hinged devices — `.unknown` until the system reports it.
  ///
  /// ```swift
  /// @SharedReader(.hingeStatus) var hingeStatus
  /// ```
  public static var hingeStatus: Self {
    Self[HingeStatusKey(), default: .unknown]
  }
}

/// Observes the hinge through a `UIHingeInteraction` on the active window scene's window, moving it
/// to whichever scene activates last. The interaction reports the current state as soon as it is
/// added, so the value needs no separate load.
public struct HingeStatusKey: SharedReaderKey {
  public typealias Value = HingeStatus?

  public var id: HingeStatusKeyID {
    HingeStatusKeyID()
  }

  public init() {}

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    // No hinged device runs an iOS without `UIHinge`, so an older system reports none.
    guard #available(iOS 27.1, *) else { return continuation.resume(returning: nil) }
    continuation.resumeReturningInitialValue()
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    guard #available(iOS 27.1, *) else { return SharedSubscription {} }

    let task = Task { @MainActor in
      let interaction = UIHingeInteraction { interaction, update in
        // Moving between windows reports a `nil` hinge for the one left; only an attached
        // interaction says whether this device has a hinge.
        guard interaction.view != nil else { return }
        subscriber.yield(update.hinge.map { HingeStatus($0.status) })
      }

      for await scene in UIApplication.shared.windowSceneActivations {
        interaction.view?.removeInteraction(interaction)
        (scene.keyWindow ?? scene.windows.first)?.addInteraction(interaction)
      }

      interaction.view?.removeInteraction(interaction)
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct HingeStatusKeyID: Hashable {}

@available(iOS 27.1, *)
extension HingeStatus {
  init(_ status: UIHinge.Status) {
    switch status {
    case .closed: self = .closed
    case .partiallyOpen: self = .partiallyOpen
    case .fullyOpen: self = .fullyOpen
    default: self = .unknown
    }
  }
}

#endif
