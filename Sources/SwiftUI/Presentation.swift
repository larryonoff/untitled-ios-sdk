import ComposableArchitecture
import DuckUIKit
import SwiftUI

extension View {
  @_spi(Presentation) public func presentation<State, Action, Content: View>(
    _ item: Binding<Store<State, Action>?>,
    transitionController: any UIViewControllerTransitioningDelegate,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content
  ) -> some View {
    self.background(
      _PresentationModifier(
        item: item,
        transitionController: transitionController,
        content: content
      )
    )
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
private struct _PresentationModifier<State, Action, Content: View>: UIViewRepresentable {
  let item: Binding<Store<State, Action>?>
  let transitionController: any UIViewControllerTransitioningDelegate
  @ViewBuilder let content: (Store<State, Action>) -> Content

  func makeCoordinator() -> Coordinator {
    return Coordinator(transitionController: transitionController)
  }

  func makeUIView(context: Context) -> UIView {
    return context.coordinator.view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.presentOrDismiss(isPresented: Binding(item)) {
      _HostingController(
        rootView: ZStack {
          if let store = item.wrappedValue {
            content(store)
          }
        }
        .environment(\.self, context.environment)
      )
    }
  }

  @MainActor
  final class Coordinator {
    let view = UIView()

    private let transitionController: any UIViewControllerTransitioningDelegate
    private weak var presentedViewController: UIViewController?

    init(
      transitionController: any UIViewControllerTransitioningDelegate
    ) {
      self.transitionController = transitionController
    }

    func presentOrDismiss(
      isPresented: Binding<Bool>,
      content: () -> UIViewController
    ) {
      let isViewPresented = presentedViewController != nil

      switch (isViewPresented, isPresented.wrappedValue) {
      case (false, false):
        break
      case (false, true):
        guard let parent = view.parentViewController else {
          isPresented.wrappedValue = false
          return
        }

        let viewController = content()
        viewController.transitioningDelegate = transitionController
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .crossDissolve

        UIViewController.presentInQueue(
          viewController,
          presentingViewController: parent.presenter,
          animated: true
        )

        presentedViewController = viewController
      case (true, false):
        presentedViewController?.dismissInQueue(animated: true)
        presentedViewController = nil
      case (true, true):
        break
      }
    }
  }
}

private final class _HostingController<Content: View>: UIHostingController<Content> {}

private extension UIViewController {
  var presenter: UIViewController {
    // Note: creating a UIViewController inside here results in a nil window

    // This is a bit of a hack: We traverse the view hierarchy looking for the most reasonable VC to present from.
    // A VC hosted within a SwiftUI cell, for example, doesn't have a parent, so we need to find the UIWindow.
    let presentingViewController: UIViewController =
      self.view.window?.topMostViewController ?? self

    return presentingViewController.topMostViewController
  }
}
