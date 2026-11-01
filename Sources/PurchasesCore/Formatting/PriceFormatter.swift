import Foundation

/// One operation owns its formatter and all configuration, including concurrent callers.
struct PriceFormatter: Sendable {
  let locale: Locale
  let roundingMode: NumberFormatter.RoundingMode
  let usesSeparator: Bool

  func string(from value: Decimal) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = locale
    formatter.roundingMode = roundingMode

    switch locale.region?.identifier {
    case "RU", "IN", "JP":
      formatter.minimumFractionDigits = 0
    default:
      formatter.minimumFractionDigits = 2
    }

    switch locale.currency?.identifier {
    case "USD":
      formatter.currencySymbol = "$"
      formatter.positiveFormat = "¤0.00"
      formatter.negativeFormat = "-¤0.00"
    case "RUB":
      formatter.currencySymbol = "₽"
      formatter.positiveFormat = "0.##¤"
      formatter.negativeFormat = "-0.##¤"
    default:
      break
    }

    let result = formatter.string(from: NSDecimalNumber(decimal: value))
    return usesSeparator ? result : result?.filter { !$0.isWhitespace }
  }
}
