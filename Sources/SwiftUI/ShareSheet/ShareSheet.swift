#if canImport(UIKit)

import IssueReporting
import SwiftUI
import SwiftUINavigation
import UIKit

extension View {
  /// Presents the system share sheet while `state` is non-`nil`.
  ///
  /// UIKit presents it itself — a sheet on iPhone, a popover anchored to this view
  /// on iPad — rather than nesting it in a SwiftUI `.sheet`, whose container and
  /// detents fight the share sheet's own.
  ///
  /// - Parameters:
  ///   - state: The sheet to present. Set to `nil` once it goes away, whoever
  ///     closes it.
  ///   - handler: Called with the action of the ``ShareActionState`` chosen, once
  ///     the sheet has closed.
  public func shareSheet<Action>(
    _ state: Binding<ShareSheetState<Action>?>,
    action handler: @escaping (Action) -> Void
  ) -> some View {
    shareSheet(item: state, state: { $0 }, action: { handler($1) })
  }

  /// Presents the system share sheet, with no actions of the app's own, while
  /// `state` is non-`nil`.
  public func shareSheet(_ state: Binding<ShareSheetState<Never>?>) -> some View {
    shareSheet(state) { _ in }
  }

  /// Presents the share sheet an `item` describes while it is non-`nil`, sending
  /// the chosen action to that item — the building block for a store-driven sheet.
  @_spi(Presentation)
  public func shareSheet<Item, Action>(
    item: Binding<Item?>,
    state: @escaping (Item) -> ShareSheetState<Action>,
    action handler: @escaping (Item, Action) -> Void
  ) -> some View {
    presentation(item) { value in
      UIActivityViewController(
        state: state(value),
        handler: { handler(value, $0) },
        onClose: { item.wrappedValue = nil }
      )
    }
  }
}

private extension UIActivityViewController {
  convenience init<Action>(
    state: ShareSheetState<Action>,
    handler: @escaping (Action) -> Void,
    onClose: @escaping () -> Void
  ) {
    let activities = state.actions.map(ActionActivity.init)

    self.init(activityItems: state.items, applicationActivities: activities)
    excludedActivityTypes = state.excludedActivities.map { UIActivity.ActivityType($0.rawValue) }
    // Runs once the sheet has closed — or, with `activityType` set and nothing
    // completed, once the person backs out of an activity onto the sheet again.
    completionWithItemsHandler = { activityType, isCompleted, _, error in
      // Nothing to hand the caller — the activity has its own UI for the person —
      // but a failing one (Save to Files, an extension) should not go unnoticed.
      if let error {
        reportIssue(error, "Share activity \(activityType?.rawValue ?? "unknown") failed")
      }

      if isCompleted, let index = activities.firstIndex(where: { $0.activityType == activityType }) {
        // The receiver clears the state: TCA's `ifLet` does, unless the action
        // presented a follow-up that clearing it here would wipe.
        handler(state.actions[index].action)
      } else if isCompleted || activityType == nil {
        // A system activity or a cancellation. Cleared here rather than left to
        // deallocation, which a controller UIKit keeps alive would never reach.
        onClose()
      }
    }
  }
}

/// Lists a ``ShareActionState`` in the sheet. Performing it only finishes; the
/// completion handler sends its action once the sheet has closed.
private final class ActionActivity: UIActivity {
  private let image: UIImage?
  private let title: String
  private let type: UIActivity.ActivityType

  init<Action>(_ state: ShareActionState<Action>) {
    self.image = switch state.image {
    case let .resource(resource): UIImage(resource: resource)
    case let .system(name): UIImage(systemName: name)
    }
    self.title = String(state: state.label)
    self.type = UIActivity.ActivityType(state.id.uuidString)
    super.init()
  }

  override var activityImage: UIImage? {
    image
  }

  override var activityTitle: String? {
    title
  }

  override var activityType: UIActivity.ActivityType? {
    type
  }

  override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    true
  }

  override func perform() {
    activityDidFinish(true)
  }
}

#endif
