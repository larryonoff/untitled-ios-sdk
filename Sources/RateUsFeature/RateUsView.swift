import ComposableArchitecture
import DuckAnalyticsClient
import DuckSwiftUI
import SwiftUI

extension View {
  /// Presents the rate-us ask as a content-sized sheet with no header art.
  public func rateUs(
    _ item: Binding<StoreOf<RateUs>?>
  ) -> some View {
    rateUs(item) { _ in EmptyView() }
  }

  /// Presents the rate-us ask as a content-sized sheet, with `header` drawn
  /// above the copy.
  ///
  /// The header receives the step on screen, so it can react when the user
  /// moves from the review ask to the support one. It is treated as decoration
  /// and hidden from VoiceOver. The sheet sizes itself to its content, so the
  /// header must report a resolvable height.
  public func rateUs<Header: View>(
    _ item: Binding<StoreOf<RateUs>?>,
    @ViewBuilder header: @escaping (RateUs.State.Intent) -> Header
  ) -> some View {
    sheet(item: item) { store in
      RateUsView(store: store, header: header)
        .presentationSizingFitted()
        .sheetCardBackground()
    }
  }
}

public struct RateUsView<Header: View>: View {
  public let store: StoreOf<RateUs>

  private let header: (RateUs.State.Intent) -> Header

  public init(
    store: StoreOf<RateUs>,
    @ViewBuilder header: @escaping (RateUs.State.Intent) -> Header
  ) {
    self.store = store
    self.header = header
  }

  public var body: some View {
    VStack(spacing: 24) {
      header(store.intent)
        .accessibilityHidden(true)

      // One view whose copy changes, not a view per step: an outgoing step
      // stays in the layout until its removal transition ends, so swapping
      // views resizes the content-sized sheet twice — once at the start of the
      // transition and again, as a visible jump, at its end.
      StepContent(store: store)
    }
    .padding(.top, 40)
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity)
    // An overlay, not a row: the sheet is content-sized, so the button must not
    // change its height between the two steps.
    .overlay(alignment: .topLeading) {
      if store.intent == .support {
        Button {
          store.send(.backTapped)
        } label: {
          Label {
            Text(.RateUs.backAction)
          } icon: {
            Image(systemName: "chevron.backward")
              .font(.system(size: 17, weight: .semibold))
              .frame(width: 20, height: 20)
          }
          .labelStyle(.iconOnly)
        }
        .rateUsBackButton()
        .padding(16)
        .transition(.opacity)
      }
    }
    .animation(.rateUsIntent, value: store.intent)
    .onAppear {
      store.send(.onAppear)
    }
  }
}

extension RateUsView where Header == EmptyView {
  public init(store: StoreOf<RateUs>) {
    self.init(store: store) { _ in EmptyView() }
  }
}

// MARK: - Content

private struct StepContent: View {
  let store: StoreOf<RateUs>

  var body: some View {
    let intent = store.intent

    VStack(spacing: 0) {
      RateUsMessage(title: intent.title, subtitle: intent.subtitle)

      // The support step has nothing to offer without a contact address. The
      // button leaves at once so the sheet shrinks with the crossfade rather
      // than after it.
      if intent == .review || store.contactURL != nil {
        Button {
          store.send(intent.primaryAction)
        } label: {
          Text(intent.primaryActionTitle)
        }
        .buttonStyle(.sheetActionPrimary)
        .padding(.top, 40)
        .transition(.asymmetric(insertion: .opacity, removal: .identity))
      }

      Button {
        store.send(intent.secondaryAction)
      } label: {
        Text(intent.secondaryActionTitle)
      }
      .buttonStyle(.sheetActionSecondary)
    }
    .contentTransition(.opacity)
  }
}

// MARK: - Message

private struct RateUsMessage: View {
  let title: LocalizedStringResource
  let subtitle: LocalizedStringResource

  private static let maxWidth: CGFloat = 300

  var body: some View {
    VStack(spacing: 16) {
      Text(title)
        .font(.system(size: 23, weight: .semibold))
        .foregroundStyle(.primary)
        .minimumScaleFactor(0.7)

      Text(subtitle)
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(.secondary)
        .minimumScaleFactor(0.8)
    }
    .multilineTextAlignment(.center)
    .lineLimit(2)
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: Self.maxWidth)
  }
}

// MARK: - Back Button

private extension View {
  /// A circular glass button on iOS 26+, matching the system's own sheet
  /// toolbar buttons on the glass sheet; a quiet chevron below.
  @ViewBuilder
  func rateUsBackButton() -> some View {
    if #available(iOS 26, macOS 26, *) {
      buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    } else {
      buttonStyle(RateUsBackButtonStyle())
    }
  }
}

private struct RateUsBackButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(.secondary)
      .frame(width: 44, height: 44)
      .contentShape(.circle)
      .opacity(configuration.isPressed ? 0.5 : 1)
  }
}

// MARK: - Transition

private extension Animation {
  static var rateUsIntent: Animation {
    .smooth
  }
}

// MARK: - Mappings

private extension RateUs.State.Intent {
  var title: LocalizedStringResource {
    switch self {
    case .review: .RateUs.title
    case .support: .RateUs.DoNotLove.title
    }
  }

  var subtitle: LocalizedStringResource {
    switch self {
    case .review: .RateUs.subtitle
    case .support: .RateUs.DoNotLove.subtitle
    }
  }

  var primaryAction: RateUs.Action {
    switch self {
    case .review: .loveTapped
    case .support: .contactSupportTapped
    }
  }

  var primaryActionTitle: LocalizedStringResource {
    switch self {
    case .review: .RateUs.loveAction
    case .support: .RateUs.shareAction
    }
  }

  var secondaryAction: RateUs.Action {
    switch self {
    case .review: .doNotLoveTapped
    case .support: .cancelTapped
    }
  }

  var secondaryActionTitle: LocalizedStringResource {
    switch self {
    case .review: .RateUs.doNotLoveAction
    case .support: .RateUs.dismissAction
    }
  }
}

// MARK: - Preview

#Preview("Rate Us", traits: .fixedLayout(width: 393, height: 480)) {
  withDependencies {
    $0.analytics = .noop
  } operation: {
    RateUsView(
      store: Store(
        initialState: RateUs.State(contactURL: nil, placement: nil)
      ) {
        RateUs()
      }
    )
  }
}

#Preview("Rate Us – Support", traits: .fixedLayout(width: 393, height: 480)) {
  var state = RateUs.State(contactURL: URL(string: "mailto:support@example.com"), placement: nil)
  state.intent = .support

  return withDependencies {
    $0.analytics = .noop
  } operation: {
    RateUsView(store: Store(initialState: state) { RateUs() })
  }
}
