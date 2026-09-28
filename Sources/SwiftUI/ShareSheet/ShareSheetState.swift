#if canImport(UIKit)

import SwiftUI
import SwiftUINavigation

/// A data type that describes the state of a share sheet: what it shares and the
/// app's own actions, listed after the system's.
///
/// Modelled on `AlertState`: held as optional state, presented with
/// ``SwiftUI/View/shareSheet(_:action:)``, and compared in tests like any value.
///
/// ```swift
/// state.shareSheet = ShareSheetState(items: [url], excluding: [.saveToCameraRoll]) {
///   ShareActionState(action: .saveToLibrary, systemImage: "square.and.arrow.down") {
///     TextState("Save to Library")
///   }
/// }
/// ```
///
/// Choosing an action sends it and closes the sheet; a system activity or a
/// cancellation only closes it.
///
/// As a case of a `@Reducer enum`, mark it `@ReducerCaseEphemeral`: the macro
/// adds that to `AlertState` by its name, and cannot recognise this type.
///
/// ```swift
/// @Reducer
/// enum Destination {
///   @ReducerCaseEphemeral
///   case shareSheet(ShareSheetState<Never>)
/// }
/// ```
public struct ShareSheetState<Action>: Identifiable {
  public let id: UUID
  public var actions: [ShareActionState<Action>]
  public var excludedActivities: [ShareActivity]
  public var items: [any Hashable & Sendable]

  public init(
    items: [any Hashable & Sendable],
    excluding excludedActivities: [ShareActivity] = [],
    @ShareActionStateBuilder<Action> actions: () -> [ShareActionState<Action>] = { [] }
  ) {
    self.id = UUID()
    self.actions = actions()
    self.excludedActivities = excludedActivities
    self.items = items
  }
}

/// An action of the app's own in a ``ShareSheetState``, described like `ButtonState`
/// plus the image the sheet shows next to it.
public struct ShareActionState<Action>: Identifiable {
  public let id: UUID
  public let action: Action
  public let label: TextState
  let image: Image

  /// Creates an action labelled with a system image.
  public init(
    action: Action,
    systemImage: String,
    label: () -> TextState
  ) {
    self.id = UUID()
    self.action = action
    self.label = label()
    self.image = .system(systemImage)
  }

  /// Creates an action labelled with an image from the asset catalog.
  public init(
    action: Action,
    image: ImageResource,
    label: () -> TextState
  ) {
    self.id = UUID()
    self.action = action
    self.label = label()
    self.image = .resource(image)
  }

  enum Image: Equatable, Sendable {
    case resource(ImageResource)
    case system(String)
  }
}

@resultBuilder
public enum ShareActionStateBuilder<Action> {
  public static func buildBlock(
    _ components: [ShareActionState<Action>]...
  ) -> [ShareActionState<Action>] {
    components.flatMap(\.self)
  }

  public static func buildEither(
    first component: [ShareActionState<Action>]
  ) -> [ShareActionState<Action>] {
    component
  }

  public static func buildEither(
    second component: [ShareActionState<Action>]
  ) -> [ShareActionState<Action>] {
    component
  }

  public static func buildExpression(
    _ expression: ShareActionState<Action>
  ) -> [ShareActionState<Action>] {
    [expression]
  }

  public static func buildOptional(
    _ component: [ShareActionState<Action>]?
  ) -> [ShareActionState<Action>] {
    component ?? []
  }
}

// Like `AlertState`, identity is left out: two sheets describing the same share
// are equal, which is what a test asserts.

extension ShareActionState: Equatable where Action: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.action == rhs.action && lhs.label == rhs.label && lhs.image == rhs.image
  }
}

extension ShareActionState: Sendable where Action: Sendable {}

extension ShareSheetState: Equatable where Action: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.actions == rhs.actions
      && lhs.excludedActivities == rhs.excludedActivities
      && lhs.items.map { AnyHashable($0) } == rhs.items.map { AnyHashable($0) }
  }
}

extension ShareSheetState: Sendable where Action: Sendable {}

#endif
