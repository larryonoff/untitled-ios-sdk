import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

extension View {
  /// Presents the notifications soft ask as a sheet sized to its content.
  public func notificationsAccessRequest(
    _ item: Binding<StoreOf<NotificationsAccessRequest>?>
  ) -> some View {
    sheet(item: item) { store in
      NotificationsAccessRequestView(store: store)
        .presentationSizingFitted()
        .sheetCardBackground()
        .interactiveDismissDisabled()
    }
  }
}

public struct NotificationsAccessRequestView: View {
  public let store: StoreOf<NotificationsAccessRequest>

  public init(store: StoreOf<NotificationsAccessRequest>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 24) {
      Header()

      VStack(spacing: 8) {
        Text(.NotificationsAccess.title)
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(.primary)
          .multilineTextAlignment(.center)
          .minimumScaleFactor(0.7)
          .lineLimit(2)

        Text(.NotificationsAccess.description)
          .font(.system(size: 16))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .minimumScaleFactor(0.8)
          .lineLimit(5)
      }
      .fixedSize(horizontal: false, vertical: true)

      VStack(spacing: 12) {
        Button {
          store.send(.notifyButtonTapped)
        } label: {
          Text(.NotificationsAccess.notifyAction)
        }
        .sheetActionPrimaryButton()

        Button {
          store.send(.laterButtonTapped)
        } label: {
          Text(.NotificationsAccess.laterAction)
        }
        .sheetActionSecondaryButton()
      }
    }
    .padding(.top, 32)
    .padding(.horizontal, 16)
    .padding(.bottom, 24)
    .frame(maxWidth: .infinity)
    // The sheet is a question with two answers, so VoiceOver focus stays inside
    // it rather than wandering into the dimmed content behind.
    .accessibilityElement(children: .contain)
    .onAppear {
      store.send(.onAppear)
    }
  }
}

// MARK: - Header

/// The illustration standing in for the app's own artwork.
///
/// Deliberately a symbol rather than a bundled image: every app that ships this
/// sheet has its own mascot or screenshot, and a neutral bell keeps the SDK from
/// dictating it. A fixed frame so the sheet — which sizes itself to its content
/// — always has a resolvable height.
private struct Header: View {
  var body: some View {
    Image(systemName: "bell.badge.fill")
      .font(.system(size: 40, weight: .semibold))
      .foregroundStyle(.tint)
      .frame(width: 96, height: 96)
      .background(Circle().fill(.tint.opacity(0.15)))
      .accessibilityHidden(true)
  }
}
