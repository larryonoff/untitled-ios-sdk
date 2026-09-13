#if canImport(UIKit)

import DuckUIKit
import SwiftUI
import UIKit

/// Where a full-screen cover is presented.
///
/// An open value type rather than an `enum`, so a new presentation context is additive.
public struct CoverPresentation: Sendable {
  /// A dedicated window layered above the app's own.
  ///
  /// - Parameter level: The window's level.
  public static func window(level: UIWindow.Level) -> Self {
    Self(windowLevel: level)
  }

  /// A dedicated window just above the app's own.
  public static let window = Self.window(level: .normal + 1)

  // Not public: an implementation detail, and a public stored property would freeze the
  // type's layout into the API.
  let windowLevel: UIWindow.Level
}

extension View {
  /// Presents `content` in a dedicated window above every modal in the app.
  ///
  /// Unlike the system `fullScreenCover(item:onDismiss:content:)`, the content is hosted in
  /// its own `UIWindow` layered above the app's, so it appears above whatever is already on
  /// screen — including other full-screen covers. A system cover attached higher in the
  /// hierarchy cannot do this: if a descendant is already presenting one, the ancestor's
  /// cover simply never appears.
  ///
  /// Because the presentation leaves the app's window it does not take part in the system
  /// presentation protocol: `@Environment(\.dismiss)` inside `content` does not reach the
  /// presenter, and `presentationBackground`, safe-area insets and preferences do not cross
  /// the window boundary. Dismiss by setting `item` to `nil`; observe dismissal with
  /// `onDismiss`. The presenter's environment is forwarded to `content` — captured once, at
  /// presentation time — so `colorScheme`, `tint` and Dynamic Type resolve as they do at the
  /// call site.
  ///
  /// While presented, replacing `item` with another non-`nil` value re-renders `content` in
  /// place, preserving its `@State`.
  ///
  /// - Note: Overloads the system modifier, distinguished by the mandatory `in` label. Should
  ///   SwiftUI ever ship an `in:`-labelled variant of its own, a more constrained generic
  ///   there would win overload ranking silently — rename this one if that happens.
  @available(iOSApplicationExtension, unavailable)
  public func fullScreenCover<Item, Content: View>(
    item: Binding<Item?>,
    in presentation: CoverPresentation,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    modifier(
      WindowCover(
        item: item,
        presentation: presentation,
        onDismiss: onDismiss,
        content: content
      )
    )
  }
}

/// Captures the presenter's environment so the hosted root can be re-seeded with it — the
/// window starts a fresh SwiftUI graph that would otherwise inherit the window's defaults.
private struct WindowCover<Item, Presented: View>: ViewModifier {
  @Binding var item: Item?
  let presentation: CoverPresentation
  let onDismiss: (() -> Void)?
  @ViewBuilder let content: (Item) -> Presented

  // Subscribes to *every* environment key, so this modifier's `body` re-runs on any
  // environment write above it — including high-frequency ones (a window resize) and
  // closure-valued keys, which never compare equal. That cost is contained on purpose: `body`
  // only rebuilds the zero-sized presenter, and the coordinator keeps using the environment it
  // presented with, so a live cover is never re-rendered by an unrelated environment change.
  // Forwarding the whole environment is the point — the hosted window starts a fresh graph and
  // would otherwise resolve `colorScheme`, `tint` and Dynamic Type from the window's defaults.
  @Environment(\.self) private var environment

  func body(content base: Content) -> some View {
    base.background {
      WindowCoverPresenter(
        item: $item,
        presentation: presentation,
        environment: environment,
        onDismiss: onDismiss,
        content: content
      )
      // The presenter is plumbing, not layout: it exists only to hold a `UIView` whose window
      // resolves the scene, and to get an update pass when `item` changes.
      .frame(width: 0, height: 0)
      .accessibilityHidden(true)
      .allowsHitTesting(false)
    }
  }
}

/// Drives the window off `item`.
///
/// A `UIViewRepresentable` in the presenter's own background, so the window is created and
/// released by the *presenter's* update cycle. Driving it from the presented content instead
/// is what breaks: once the state is `nil` the hosted view has nothing left to observe, so
/// nothing runs to take the window down.
///
/// `@Binding`, not a plain `let`: as a `DynamicProperty` its `wrappedValue` is read when
/// SwiftUI evaluates the representable, which is what subscribes the graph to `item`. A plain
/// `let Binding` is opaque to the graph, and `updateUIView` would never run in release.
@MainActor
private struct WindowCoverPresenter<Item, Presented: View>: UIViewRepresentable {
  @Binding var item: Item?
  let presentation: CoverPresentation
  let environment: EnvironmentValues
  let onDismiss: (() -> Void)?
  let content: (Item) -> Presented

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  func makeUIView(context: Context) -> UIView {
    context.coordinator.view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.presentation = presentation
    context.coordinator.onDismiss = onDismiss
    context.coordinator.content = content
    // Only used for a presentation started from here on; the live one keeps the environment
    // it was presented with, so re-rendering never replaces the whole `EnvironmentValues`
    // (it is not `Equatable`, so that would invalidate the entire hosted tree).
    context.coordinator.pendingEnvironment = environment
    context.coordinator.update(item: $item)
  }

  static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
    // The presenter left the hierarchy while the cover was up. A visible window attached to
    // a scene keeps itself alive, so without this the window would stay on screen forever —
    // covering the app with no way back.
    coordinator.tearDownImmediately()
  }

  @MainActor
  final class Coordinator {
    let view = UIView()

    var presentation: CoverPresentation = .window
    var onDismiss: (() -> Void)?
    var content: ((Item) -> Presented)?
    var pendingEnvironment = EnvironmentValues()

    // Both strong: the coordinator owns the presentation. A `weak` controller could be
    // released the moment a queued present fails, leaving a live window with no content —
    // an invisible cover that state still believes is on screen.
    private var window: UIWindow?
    private var hostingController: CoverHostingController<HostedCover<Presented>>?

    /// The environment the live presentation was created with. Kept so re-rendering reuses it
    /// instead of pushing a fresh `EnvironmentValues` (not `Equatable`, so a new one would
    /// invalidate the whole hosted tree).
    private var presentedEnvironment: EnvironmentValues?

    /// Bumped whenever the presentation changes, so a teardown scheduled by an earlier
    /// dismissal can tell it has been superseded — `item` can flip back to non-`nil` while the
    /// dismiss animation is still running.
    private var generation = 0

    func update(item: Binding<Item?>) {
      switch (window, item.wrappedValue) {
      case (nil, .none):
        break

      case let (nil, .some(value)):
        present(value, item: item)

      case let (.some, .some(value)):
        guard let content, let hostingController else {
          // A window with no controller is a presentation that never landed. Take it down and
          // let the caller's state settle rather than leaving an invisible cover up.
          tearDown()
          clear(item)
          break
        }

        // Supersede a teardown scheduled by a dismissal still animating out: the cover is
        // wanted again, so it must not be destroyed when that completion arrives.
        generation += 1

        // Re-render in place. Reassigning `rootView` keeps the hosted `@State` — timers,
        // players — alive, which rebuilding the controller would not.
        hostingController.rootView = HostedCover(
          content: content(value),
          environment: presentedEnvironment ?? pendingEnvironment
        )

      case (.some, .none):
        dismiss()
      }
    }

    private func present(_ value: Item, item: Binding<Item?>) {
      guard
        let content,
        let scene = view.window?.windowScene ?? UIApplication.shared.activeScene
      else {
        // Nothing to present into: not in a hierarchy yet, or no foreground-active scene.
        // Clear the binding rather than failing silently — the caller may be holding a slot
        // open for a presentation that is never going to happen.
        clear(item)
        return
      }

      generation += 1

      let environment = pendingEnvironment
      presentedEnvironment = environment

      let window = UIWindow(windowScene: scene)
      window.windowLevel = presentation.windowLevel
      window.backgroundColor = .clear
      // From the presenter's environment, not a parameter: SwiftUI colors inside the cover
      // already come from the forwarded environment, and the UIKit status bar reads the
      // window — so both have to agree, and `colorScheme` is the single source for that.
      window.overrideUserInterfaceStyle = UIUserInterfaceStyle(environment.colorScheme)

      let root = UIViewController()
      root.view.backgroundColor = .clear
      // The root fills the window, so it would swallow taps in the moments the window is up
      // without a cover on top of it: while presenting, and during the dismiss animation.
      root.view.isUserInteractionEnabled = false
      window.rootViewController = root

      // Key, not merely visible: a non-key window does not reliably own first responder, so
      // text input inside the cover would never get a keyboard.
      window.makeKeyAndVisible()

      let hostingController = CoverHostingController(
        rootView: HostedCover(content: content(value), environment: environment)
      )
      hostingController.modalPresentationStyle = .fullScreen
      // Lets the hosted controller, rather than the empty root, decide the status bar.
      hostingController.modalPresentationCapturesStatusBarAppearance = true

      self.window = window
      self.hostingController = hostingController

      let generation = generation

      UIViewController.presentInQueue(
        hostingController,
        presentingViewController: root,
        animated: true
      ) { [weak self] isPresented in
        guard let self, !isPresented, generation == self.generation else { return }

        // The presentation never landed — the queue could not find a presenter. Without this
        // the window would stay up, empty and invisible, while the caller's state still says a
        // cover is on screen.
        self.tearDown()
        self.clear(item)
      }
    }

    private func dismiss() {
      guard let hostingController else {
        tearDown()
        notifyDismissed()
        return
      }

      generation += 1
      let generation = generation

      hostingController.dismissInQueue(animated: true) { [weak self] in
        guard let self, generation == self.generation else {
          // Superseded: the cover was wanted again while this dismissal animated out, so the
          // presentation that replaced it owns the window now.
          return
        }
        self.tearDown()
        self.notifyDismissed()
      }
    }

    /// Takes the window down without queueing a dismissal, for when the presenter itself is
    /// going away and there is nothing left to animate.
    func tearDownImmediately() {
      let hadPresentation = window != nil
      tearDown()
      if hadPresentation {
        notifyDismissed()
      }
    }

    private func tearDown() {
      generation += 1

      // Dropping the root controller dismantles the presentation synchronously; queueing a
      // dismissal here instead would block the app-wide presentation queue on a semaphore
      // whose completion never arrives once the window is gone.
      window?.rootViewController = nil
      // Hiding a key window makes UIKit promote the next one automatically — no need to
      // restore the app's window by hand.
      window?.isHidden = true
      window = nil
      hostingController = nil
      presentedEnvironment = nil
    }

    private func notifyDismissed() {
      onDismiss?()
    }

    /// Clears `item` after the current update pass: writing a binding from within
    /// `updateUIView` mutates state mid-update, and for a store-backed binding that reenters
    /// the reducer.
    private func clear(_ item: Binding<Item?>) {
      Task { @MainActor in
        item.wrappedValue = nil
      }
    }

    deinit {
      // Runs on the main actor: the coordinator's lifetime is driven by SwiftUI, which
      // releases it there.
      MainActor.assumeIsolated {
        window?.rootViewController = nil
        window?.isHidden = true
      }
    }
  }
}

/// The hosted root: `content` re-seeded with the presenter's environment.
///
/// A concrete view rather than `AnyView`, so SwiftUI matches view identity structurally across
/// `rootView` reassignments and the hosted `@State` survives.
private struct HostedCover<Content: View>: View {
  let content: Content
  let environment: EnvironmentValues

  var body: some View {
    content
      .environment(\.self, environment)
  }
}

private extension UIUserInterfaceStyle {
  init(_ colorScheme: ColorScheme) {
    switch colorScheme {
    case .dark: self = .dark
    case .light: self = .light
    @unknown default: self = .unspecified
    }
  }
}

/// Hosts the cover's content. Its own type, not shared with the other presentation seams in
/// this module: each owns its hosting controller so one seam's configuration can never change
/// another's behavior.
private final class CoverHostingController<Content: View>: UIHostingController<Content> {}

#endif
