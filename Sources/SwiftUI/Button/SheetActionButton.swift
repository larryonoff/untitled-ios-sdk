import SwiftUI

/// Full-width action buttons for the app's bottom sheets (Rate Us, the
/// notifications soft-ask): an 80pt-tall capsule pair, filled primary over a
/// bare secondary. Mirrors BEAT's `SharedUI/SheetActionButton`.
public struct SheetActionPrimaryButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    InvertedCapsule(configuration: configuration)
  }

  /// The inverted surface is spelled with literal colors on purpose: inside an
  /// iOS 26 glass sheet the adaptive `.primary`/`.background` styles resolve to
  /// their vibrancy variants, which washes the capsule and its label out to
  /// two shades of grey.
  private struct InvertedCapsule: View {
    let configuration: Configuration

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
      let shape = Capsule()

      configuration.label
        .sheetActionLabel()
        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
        .background(colorScheme == .dark ? Color.white : Color.black, in: shape)
        .clipShape(shape)
        .opacity(configuration.isPressed ? 0.85 : 1)
    }
  }
}

public struct SheetActionSecondaryButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .sheetActionLabel()
      .foregroundStyle(.secondary)
      .opacity(configuration.isPressed ? 0.5 : 1)
  }
}

extension ButtonStyle where Self == SheetActionPrimaryButtonStyle {
  public static var sheetActionPrimary: Self { Self() }
}

extension ButtonStyle where Self == SheetActionSecondaryButtonStyle {
  public static var sheetActionSecondary: Self { Self() }
}

extension View {
  /// The confirm action of a sheet that wants the system's glass on iOS 26+:
  /// prominent glass there, the filled capsule below.
  @ViewBuilder
  public func sheetActionPrimaryButton() -> some View {
    if #available(iOS 26, macOS 26, *) {
      buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
    } else {
      buttonStyle(.sheetActionPrimary)
    }
  }

  /// The decline action of a bottom sheet: quiet text, so the confirm action
  /// stays the obvious one.
  public func sheetActionSecondaryButton() -> some View {
    buttonStyle(.sheetActionSecondary)
  }

  /// Shared metrics of both sheet action buttons, so the filled and bare
  /// variants stay the same size when stacked.
  public func sheetActionLabel() -> some View {
    font(.system(size: 17, weight: .bold))
      .textCase(.uppercase)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .padding(.horizontal, 20)
      .frame(maxWidth: .infinity)
      .frame(height: 80)
  }
}
