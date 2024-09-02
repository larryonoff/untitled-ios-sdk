import ComposableArchitecture
@_spi(Presentation) import DuckSwiftUI
import SwiftUI

extension View {
  public func rateUs(
    _ item: Binding<StoreOf<RateUs>?>
  ) -> some View {
    self.sheet(item: item) { store in
      RateUsView(store: store)
        .presentationDetents([.height(272)])
        ._presentationCornerRadius(24)
    }
  }
}

private extension View {
  func _presentationCornerRadius(_ cornerRadius: CGFloat) -> some View {
    if #available(iOS 16.4, *) {
      return self.presentationCornerRadius(cornerRadius)
    } else {
      return self
    }
  }
}

public struct RateUsView: View {
  public let store: StoreOf<RateUs>

  public init(store: StoreOf<RateUs>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      ZStack {
        Rectangle().fill(.background)
          .ignoresSafeArea()

        switch store.mode {
        case .default:
          DefaultRateUsView(store: store)
            .transition(.rateUsMode)
        case .doNotLove:
          DoNotLoveRateUsView(store: store)
            .transition(.rateUsMode)
        }
      }
      .animation(.default, value: store.mode)
      .onAppear {
        store.send(.onAppear)
      }
      .statusBarHidden()
    }
  }
}

private struct DefaultRateUsView: View {
  let store: StoreOf<RateUs>

  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        Text(L10n.RateUs.title)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(.primary)
          .multilineTextAlignment(.center)

        Button {
          store.send(.loveTapped)
        } label: {
          Text(L10n.RateUs.loveAction)
        }
        .buttonStyle(.rateUsPrimary)
        .padding(.top, 37)

        Button {
          store.send(.doNotLoveTapped)
        } label: {
          Text(L10n.RateUs.doNotLoveAction)
        }
        .buttonStyle(.rateUsSecondary)
        .padding(.top, 17)
      }
      .padding()
    }
  }
}

private struct DoNotLoveRateUsView: View {
  let store: StoreOf<RateUs>

  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        Text(L10n.RateUs.DoNotLove.title)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(.primary)
          .multilineTextAlignment(.center)

        Text(L10n.RateUs.DoNotLove.subtitle)
          .font(.system(size: 16, weight: .regular))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .padding(.top, 6)

        Button {
          store.send(.contactUsTapped)
        } label: {
          Text(L10n.RateUs.shareAction)
        }
        .buttonStyle(.rateUsPrimary)
        .padding(.top, 27)

        Button {
          store.send(.dismissTapped)
        } label: {
          Text(L10n.RateUs.dismissAction)
        }
        .buttonStyle(.rateUsSecondary)
        .padding(.top, 17)
      }
      .padding()
    }
  }
}

private extension AnyTransition {
  static var rateUsMode: AnyTransition {
    .scale(scale: 0.95)
    .combined(with: .opacity)
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  static var rateUsPrimary: PrimaryButtonStyle {
    PrimaryButtonStyle()
  }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
  static var rateUsSecondary: SecondaryButtonStyle {
    SecondaryButtonStyle()
  }
}

private struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 17, weight: .bold))
      .foregroundStyle(.background)
      .padding(.vertical, 14)
      .padding(.horizontal, 20)
      .frame(minWidth: 174, minHeight: 50)
      .background(.tint, in: shape)
      .clipShape(shape)
  }

  private var shape: Capsule {
    Capsule()
  }
}

private struct SecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 17, weight: .medium))
      .foregroundStyle(.primary)
  }
}
