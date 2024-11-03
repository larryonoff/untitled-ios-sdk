import DuckFoundation
import Foundation

final class PriceFormatter {
  private static var cache: [AnyHashable: NumberFormatter] = [:]
  private static let lock = NSRecursiveLock()

  private var _locale: Locale = .autoupdatingCurrent

  var locale: Locale {
    get {
      Self.lock.sync {
        self._locale
      }
    }
    set {
      Self.lock.sync {
        self._locale = newValue
      }
    }
  }

  var roundingMode: NumberFormatter.RoundingMode = .down

  init() {}

  func string(from value: Decimal) -> String? {
    let key = _FormatterKey(locale, roundingMode: roundingMode)

    return Self.formatter(for: key)
      .string(from: NSDecimalNumber(decimal: value))
  }

  private static func formatter(
    for key: _FormatterKey
  ) -> NumberFormatter {
    lock.sync {
      if let formatter = PriceFormatter.cache[key] {
        return formatter
      }

      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.locale = key.locale
      formatter.roundingMode = key.roundingMode

      switch key.locale.regionCode {
      case "RU", "IN", "JP":
        formatter.minimumFractionDigits = 0
      default:
        formatter.minimumFractionDigits = 2
      }

      switch key.locale.currencyCode {
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

      cache[key] = formatter

      return formatter
    }
  }
}

private struct _FormatterKey {
  let locale: Locale
  let roundingMode: NumberFormatter.RoundingMode

  init(
    _ locale: Locale,
    roundingMode: NumberFormatter.RoundingMode
  ) {
    self.locale = locale
    self.roundingMode = roundingMode
  }
}

extension _FormatterKey: Equatable {}
extension _FormatterKey: Hashable {}
extension _FormatterKey: Sendable {}
