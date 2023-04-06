import Foundation

final class PriceFormatter {
  private lazy var numberFormatter = buildNumberFormatter()

  private func buildNumberFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency

    return formatter
  }

  var locale: Locale = .autoupdatingCurrent {
    didSet {
      guard locale != oldValue else { return }
      localeDidChange()
    }
  }

  private func localeDidChange() {
    numberFormatter = buildNumberFormatter()
    numberFormatter.locale = locale
    numberFormatter.roundingMode = roundingMode

    switch locale.regionCode {
    case "RU", "IN", "JP":
      numberFormatter.minimumFractionDigits = 0
    default:
      numberFormatter.minimumFractionDigits = 2
    }

    switch locale.currencyCode {
    case "USD":
      numberFormatter.currencySymbol = "$"
      numberFormatter.positiveFormat = "¤0.00"
      numberFormatter.negativeFormat = "-¤0.00"
    case "RUB":
      numberFormatter.currencySymbol = "₽"
      numberFormatter.positiveFormat = "0.##¤"
      numberFormatter.negativeFormat = "-0.##¤"
    default:
      break
    }
  }

  var roundingMode: NumberFormatter.RoundingMode = .down {
    didSet {
      guard roundingMode != oldValue else { return }
      roundingModeDidChange()
    }
  }

  private func roundingModeDidChange() {
    numberFormatter.roundingMode = roundingMode
  }

  init() {}

  func string(from value: Decimal) -> String? {
    numberFormatter
      .string(from: NSDecimalNumber(decimal: value))
  }
}
