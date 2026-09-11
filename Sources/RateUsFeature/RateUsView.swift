import ComposableArchitecture
import DuckAnalyticsClient
import DuckSwiftUI
import SwiftUI

extension View {
  /// Presents the rate-us ask as a content-sized sheet: no grabber, no swipe
  /// or tap-outside exit — the two buttons are the only way out, exactly as in
  /// BEAT's `RateUsSheetController`.
  public func rateUs(
    _ item: Binding<StoreOf<RateUs>?>,
    mascotReview: Image? = nil,
    mascotSupport: Image? = nil
  ) -> some View {
    sheet(item: item) { store in
      RateUsView(
        store: store,
        mascotReview: mascotReview,
        mascotSupport: mascotSupport
      )
      .presentationSizingFitted()
      .sheetCardBackground()
      .interactiveDismissDisabled()
    }
  }
}

public struct RateUsView: View {
  public let store: StoreOf<RateUs>

  private let mascotReview: Image?
  private let mascotSupport: Image?

  public init(
    store: StoreOf<RateUs>,
    mascotReview: Image? = nil,
    mascotSupport: Image? = nil
  ) {
    self.store = store
    self.mascotReview = mascotReview
    self.mascotSupport = mascotSupport
  }

  public var body: some View {
    VStack(spacing: 24) {
      RateUsMascot(
        intent: store.intent,
        review: mascotReview,
        support: mascotSupport
      )

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

// MARK: - Content

private struct ReviewContent: View {
  let store: StoreOf<RateUs>

  var body: some View {
    VStack(spacing: 0) {
      RateUsHeader(
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
      RateUsHeader(
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

// MARK: - Mascot

/// The illustration above the copy, keyed by the step on screen.
///
/// The frame is intentionally fixed: the sheet sizes itself to its content, so
/// the mascot must report a resolvable height. Hosts without art pass nothing
/// and the slot collapses instead of leaving a blank square.
private struct RateUsMascot: View {
  let intent: RateUs.State.Intent
  let review: Image?
  let support: Image?

  var body: some View {
    if let image {
      image
        .resizable()
        .scaledToFit()
        .frame(width: 180, height: 180)
        .transition(.rateUsIntent)
        .id(intent)
        .accessibilityHidden(true)
    }
  }

  private var image: Image? {
    switch intent {
    case .review: review
    case .support: support
    }
  }
}

// MARK: - Header

private struct RateUsHeader: View {
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
