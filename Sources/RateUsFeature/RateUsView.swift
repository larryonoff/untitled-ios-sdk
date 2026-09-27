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

      switch store.intent {
      case .review:
        ReviewContent(store: store)
          .transition(.rateUsIntent)
      case .support:
        SupportContent(store: store)
          .transition(.rateUsIntent)
      }
    }
    .padding(.top, 40)
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity)
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

private struct ReviewContent: View {
  let store: StoreOf<RateUs>

  var body: some View {
    VStack(spacing: 0) {
      RateUsMessage(
        title: .RateUs.title,
        subtitle: .RateUs.subtitle
      )

      Button {
        store.send(.loveTapped)
      } label: {
        Text(.RateUs.loveAction)
      }
      .buttonStyle(.sheetActionPrimary)
      .padding(.top, 40)

      Button {
        store.send(.doNotLoveTapped)
      } label: {
        Text(.RateUs.doNotLoveAction)
      }
      .buttonStyle(.sheetActionSecondary)
      .padding(.top, 0)
    }
  }
}

private struct SupportContent: View {
  let store: StoreOf<RateUs>

  var body: some View {
    VStack(spacing: 0) {
      RateUsMessage(
        title: .RateUs.DoNotLove.title,
        subtitle: .RateUs.DoNotLove.subtitle
      )

      if store.contactURL != nil {
        Button {
          store.send(.contactSupportTapped)
        } label: {
          Text(.RateUs.shareAction)
        }
        .buttonStyle(.sheetActionPrimary)
        .padding(.top, 40)
      }

      Button {
        store.send(.cancelTapped)
      } label: {
        Text(.RateUs.dismissAction)
      }
      .buttonStyle(.sheetActionSecondary)
      .padding(.top, 0)
    }
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

// MARK: - Transition

private extension AnyTransition {
  static var rateUsIntent: AnyTransition {
    .scale(scale: 0.95)
      .combined(with: .opacity)
  }
}

private extension Animation {
  static var rateUsIntent: Animation {
    .smooth
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
