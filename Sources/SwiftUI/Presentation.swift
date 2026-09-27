#if canImport(UIKit)

import DuckUIKit
import ObjectiveC
import SwiftUI

/// Context handed to a ``SwiftUI/View/presentation(_:controller:)-8h9k2`` factory,
/// carrying the values a controller hosting SwiftUI needs from its presenter.
///
/// Modelled on `UIViewControllerRepresentableContext`. Today it exposes only the
/// environment; the type exists so future needs (transaction, a coordinator) can be
/// added without changing the factory's signature.
@_spi(Presentation)
public struct PresentationContext {
  /// The presenter's SwiftUI environment, captured at presentation time.
  public let environment: EnvironmentValues
}

extension View {
  /// Presents a controller from the window's top-most view controller, escaping the
  /// local SwiftUI view hierarchy.
  ///
  /// Unlike `.sheet`, the presenting controller is resolved from the window's top-most
  /// view controller, so the presentation lands above whatever is currently shown —
  /// including full-screen covers. The `controller` factory builds the view controller
  /// and is expected to configure its own presentation (modal style, and for a sheet
  /// its `sheetPresentationController`: detents, corner radius, modality).
  @_spi(Presentation)
  public func presentation<State, Controller: UIViewController>(
    _ item: Binding<State?>,
    controller: @escaping (State) -> Controller
  ) -> some View {
    self.background(
      _UIPresentationModifier(
        item: item,
        controller: controller
      )
    )
  }

  /// Presents a controller from the window's top-most view controller, handing the
  /// factory a ``PresentationContext`` carrying the presenter's SwiftUI environment.
  ///
  /// Use this variant of ``presentation(_:controller:)`` when the controller hosts a
  /// SwiftUI view: the custom presentation escapes the SwiftUI hierarchy into a fresh
  /// `UIHostingController`, whose environment is otherwise seeded from the window — not
  /// the presenter — so its `colorScheme`, `tint`, `layoutDirection`, Dynamic Type, … would
  /// resolve wrong. Re-apply `context.environment` to the hosted root
  /// (`content.environment(\.self, context.environment)`) to inherit the presenter's.
  ///
  /// Mirrors `UIViewControllerRepresentable`, whose factory likewise receives a context
  /// carrying the environment. The context is captured once, at presentation time;
  /// changes while the presentation is on-screen do not propagate.
  @_spi(Presentation)
  public func presentation<State, Controller: UIViewController>(
    _ item: Binding<State?>,
    controller: @escaping (State, PresentationContext) -> Controller
  ) -> some View {
    modifier(
      _HostedPresentationModifier(
        item: item,
        controller: controller
      )
    )
  }

  /// Presents SwiftUI `content` with a custom transition, escaping the local view
  /// hierarchy. Forwards the surrounding SwiftUI environment into the hosted content,
  /// then routes through ``presentation(_:controller:)``.
  @_spi(Presentation)
  public func presentation<State, Content: View>(
    _ item: Binding<State?>,
    transitionController: any UIViewControllerTransitioningDelegate,
    @ViewBuilder content: @escaping (State) -> Content
  ) -> some View {
    modifier(
      _TransitionPresentationModifier(
        item: item,
        transitionController: transitionController,
        content: content
      )
    )
  }
}

/// Captures the presenter's environment, then hands it to the controller factory via a
/// ``PresentationContext`` so a hosting controller can re-seed its SwiftUI root with it.
private struct _HostedPresentationModifier<State, Controller: UIViewController>: ViewModifier {
  @Binding var item: State?
  let controller: (State, PresentationContext) -> Controller

  @Environment(\.self) private var environment

  func body(content base: Content) -> some View {
    base.presentation($item) { state in
      controller(state, PresentationContext(environment: environment))
    }
  }
}

/// Initially the custom alert was presented by:
/// 1. Observe isPresented changes, i.e. ``.onChange(of: isPresented.wrappedValue)``
/// 2. Present alert using  top-most `UIViewController`
///
/// However, this resulted in an accidental crash:
///
/// ```
/// Fatal Exception: NSInvalidArgumentException
/// Application tried to present modally a view controller <_TtGC7SwiftUI29PresentationHostingControllerVS_7AnyView_: 0x108023d00> that is already being presented by <_TtGC7SwiftUI19UIHostingControllerGVS_15ModifiedContentVS_7AnyViewVS_12RootModifier__: 0x107e07510>.
/// ```
///
/// so we re-implemented the presentation using a similar approach as employed by stripe-ios:
/// https://github.com/stripe/stripe-ios/blob/master/StripePaymentSheet/StripePaymentSheet/Source/PaymentSheet/PaymentSheet%2BSwiftUI.swift
///
/// 1. Implement `UIViewRepresentable` with backing-`UIView`
/// 2. Search top-most view controller associated with the backing-`UIView`
/// 3. Use `UIViewRepresentable` as background modifier of a View
@MainActor
private struct _UIPresentationModifier<State, Controller: UIViewController>: UIViewRepresentable {
  // `@Binding`, not a plain `let`: as a DynamicProperty its `wrappedValue` is read when
  // SwiftUI evaluates the representable, which subscribes the graph to `item`. Callers
  // scope it as `$store.scope(state: \.destination?…)` and never read the destination as a
  // value, so without this subscription a dismiss driven by writing `item = nil` from a
  // captured closure (a dialog's Cancel / tap-outside) doesn't invalidate the graph in
  // release builds and `updateUIView` never runs. A plain `let Binding` is opaque to the
  // graph and does not subscribe.
  @Binding var item: State?
  let controller: (State) -> Controller

  func makeCoordinator() -> Coordinator {
    Coordinator(controller: controller)
  }

  func makeUIView(context: Context) -> UIView {
    context.coordinator.view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    // Refresh the factory every update: it captures the presenter's environment at
    // render time, and the coordinator outlives the struct. Keeping the first render's
    // closure would freeze the environment at install time instead of presentation time.
    context.coordinator.controller = controller
    context.coordinator.presentOrDismiss(item: $item)
  }

  static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
    coordinator.dismantle()
  }

  @MainActor
  final class Coordinator {
    let view = UIView()

    var controller: (State) -> Controller
    private weak var presentedViewController: UIViewController?

    init(controller: @escaping (State) -> Controller) {
      self.controller = controller
    }

    func presentOrDismiss(item: Binding<State?>) {
      let isViewPresented = presentedViewController != nil

      switch (isViewPresented, item.wrappedValue) {
      case (false, .none), (true, .some):
        break
      case let (false, .some(state)):
        guard let parent = view.parentViewController else {
          item.wrappedValue = nil
          return
        }

        let viewController = controller(state)
        // A dismiss the system drives (tap outside, swipe) bypasses this coordinator, so
        // without this `item` stays non-nil and the caller believes it is still on screen.
        // `presentedViewController` is weak and already `nil` by the time this runs.
        viewController.deallocationHandler = {
          item.wrappedValue = nil
        }

        UIViewController.presentInQueue(
          viewController,
          presentingViewController: parent.presenter,
          animated: true
        )

        presentedViewController = viewController
      case (true, .none):
        // Dismissed by state, which is already `nil`: nothing to write back.
        dismiss(writingBack: false)
      }
    }

    /// Takes the presentation down with its declaration, the way SwiftUI tears down a
    /// `.sheet` whose view left the hierarchy. Without this, a presenter removed while
    /// its controller is on screen leaves nothing to dismiss it when `item` turns `nil`.
    func dismantle() {
      dismiss(writingBack: true)
    }

    /// `writingBack` keeps `deallocationHandler` wired, so `item` is cleared once the
    /// dismissal lands — outside the view update that asked for it — for a state that
    /// still believes the controller is on screen.
    private func dismiss(writingBack: Bool) {
      if !writingBack {
        presentedViewController?.deallocationHandler = nil
      }
      presentedViewController?.dismissInQueue(animated: true)
      presentedViewController = nil
    }
  }
}

/// Calls `handler` when the controller it is attached to is deallocated.
///
/// Deallocation is where every dismissal ends, whoever drives it — a swipe, a tap
/// outside, the controller dismissing itself, or an ancestor taking it down — so it
/// catches them all without swizzling `viewDidDisappear`. `presentationControllerDidDismiss`
/// would cover only interactive sheet and popover dismissals, and a factory may claim
/// that delegate for itself.
///
/// - Isolation: `handler` is set on the main actor; `deinit` runs wherever the last
///   release lands. UIKit releases a system-dismissed controller on the main thread,
///   while `dismissInQueue` may drop the last reference on its operation queue — that
///   path is disarmed or has no presenter left, so the hop there is harmless.
///
/// ponytail: a controller kept alive past its dismissal (a retain cycle, a cache) never
/// fires, leaving `item` set; switch to an appearance hook if that shows up.
private final class DeallocationNotifier {
  var handler: (@MainActor @Sendable () -> Void)?

  deinit {
    guard let handler else { return }
    // Inline on the main thread, where UIKit releases a dismissed controller: a hop
    // would leave a window in which `item` is still set but nothing is presented, and
    // an update landing there would present it again.
    if Thread.isMainThread {
      MainActor.assumeIsolated(handler)
    } else {
      Task { @MainActor in handler() }
    }
  }
}

// SAFETY: never dereferenced or written; its address only identifies the
// associated object, so sharing it across isolation domains cannot race.
private nonisolated(unsafe) let deallocationNotifierKey = UnsafeRawPointer(
  UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
)

private extension UIViewController {
  var deallocationHandler: (@MainActor @Sendable () -> Void)? {
    get {
      (objc_getAssociatedObject(self, deallocationNotifierKey) as? DeallocationNotifier)?.handler
    }
    set {
      let notifier = objc_getAssociatedObject(self, deallocationNotifierKey) as? DeallocationNotifier
        ?? DeallocationNotifier()
      notifier.handler = newValue
      objc_setAssociatedObject(self, deallocationNotifierKey, notifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

/// Presents `content` (hosted + custom transition) via the context-carrying
/// ``presentation(_:controller:)``, re-seeding the hosted root with the presenter's
/// environment from ``PresentationContext``.
//
// `Presented` is the type of the presented view; named distinctly only to avoid
// colliding with `ViewModifier.Content` (the wrapped view, `base` below).
private struct _TransitionPresentationModifier<State, Presented: View>: ViewModifier {
  @Binding var item: State?
  let transitionController: any UIViewControllerTransitioningDelegate
  @ViewBuilder let content: (State) -> Presented

  func body(content base: Content) -> some View {
    base.presentation($item) { state, context in
      let viewController = _HostingController(
        rootView: content(state)
          .environment(\.self, context.environment)
      )
      viewController.transitioningDelegate = transitionController
      viewController.modalPresentationStyle = .custom
      viewController.modalTransitionStyle = .crossDissolve
      return viewController
    }
  }
}

private final class _HostingController<Content: View>: UIHostingController<Content> {}

private extension UIViewController {
  /// The most reasonable controller to present from: the top-most controller of the
  /// view's window, falling back to `self` when the view is not yet in a window.
  var presenter: UIViewController {
    // Note: creating a UIViewController inside here results in a nil window.
    // A VC hosted within a SwiftUI cell, for example, doesn't have a parent, so we
    // traverse to the UIWindow to find the most reasonable VC to present from.
    let presentingViewController = view.window?.topMostViewController ?? self
    return presentingViewController.topMostViewController
  }
}

#endif
