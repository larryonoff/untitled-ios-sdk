import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

extension View {
  /// Presents the notifications soft ask as a sheet sized to its content, with
  /// the SDK's bell above the copy.
  ///
  /// - Parameters:
  ///   - title: The app's own headline. `nil` shows the SDK's generic copy.
  ///   - message: The app's own pitch — what the user will get, and how often.
  ///     `nil` shows the SDK's generic copy.
  public func notificationsAccessRequest(
    _ item: Binding<StoreOf<NotificationsAccessRequest>?>,
    title: Text? = nil,
    message: Text? = nil
  ) -> some View {
    notificationsAccessRequest(item, title: title, message: message) {
      DefaultNotificationsAccessHeader()
    }
  }

  /// Presents the notifications soft ask as a sheet sized to its content, with
  /// `header` drawn above the copy.
  ///
  /// The header is treated as decoration and hidden from VoiceOver. The sheet
  /// sizes itself to its content, so the header must report a resolvable
  /// height.
  ///
  /// - Parameters:
  ///   - title: The app's own headline. `nil` shows the SDK's generic copy.
  ///   - message: The app's own pitch — what the user will get, and how often.
  ///     `nil` shows the SDK's generic copy.
  public func notificationsAccessRequest<Header: View>(
    _ item: Binding<StoreOf<NotificationsAccessRequest>?>,
    title: Text? = nil,
    message: Text? = nil,
    @ViewBuilder header: @escaping () -> Header
  ) -> some View {
    sheet(item: item) { store in
      NotificationsAccessRequestView(
        store: store,
        title: title,
        message: message,
        header: header
      )
        .presentationSizingFitted()
        .sheetCardBackground()
        .interactiveDismissDisabled()
    }
  }
}

public struct NotificationsAccessRequestView<Header: View>: View {
  public let store: StoreOf<NotificationsAccessRequest>

  private let header: () -> Header
  private let message: Text?
  private let title: Text?

  public init(
    store: StoreOf<NotificationsAccessRequest>,
    title: Text? = nil,
    message: Text? = nil,
    @ViewBuilder header: @escaping () -> Header
  ) {
    self.store = store
    self.header = header
    self.message = message
    self.title = title
  }

  public var body: some View {
    VStack(spacing: 24) {
      header()
        .accessibilityHidden(true)

      VStack(spacing: 8) {
        (title ?? Text(.NotificationsAccess.title))
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(.primary)
          .multilineTextAlignment(.center)
          .minimumScaleFactor(0.7)
          .lineLimit(2)

        (message ?? Text(.NotificationsAccess.description))
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

extension NotificationsAccessRequestView where Header == DefaultNotificationsAccessHeader {
  public init(
    store: StoreOf<NotificationsAccessRequest>,
    title: Text? = nil,
    message: Text? = nil
  ) {
    self.init(store: store, title: title, message: message) {
      DefaultNotificationsAccessHeader()
    }
  }
}

// MARK: - Header

/// The SDK's stand-in for the app's own artwork: a bell in the current tint.
///
/// A symbol rather than a bundled image, so the SDK doesn't dictate a mascot.
/// A fixed frame so the content-sized sheet always has a resolvable height.
/// Public so hosts can reuse it inside their own header.
public struct DefaultNotificationsAccessHeader: View {
  public init() {}

  public var body: some View {
    Image(systemName: "bell.badge.fill")
      .font(.system(size: 40, weight: .semibold))
      .foregroundStyle(.tint)
      .frame(width: 96, height: 96)
      .background(Circle().fill(.tint.opacity(0.15)))
  }
}
