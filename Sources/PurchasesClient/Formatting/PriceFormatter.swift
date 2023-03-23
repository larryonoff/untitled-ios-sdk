import Foundation

final class PriceFormatter: NumberFormatter {
  override var locale: Locale! {
    didSet { localeDidChange() }
  }

  override init() {
    super.init()
    localeDidChange()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    localeDidChange()
    roundingMode = .down
  }

  // MARK: - state changes

  private func localeDidChange() {
    switch locale.regionCode {
    case "RU", "IN", "JP":
      minimumFractionDigits = 0
    default:
      minimumFractionDigits = 2
    }

    switch locale.currencyCode {
    case "USD":
      currencySymbol = "$"
      positiveFormat = "¤0.00"
      negativeFormat = "-¤0.00"
    case "RUB":
      currencySymbol = "₽"
      positiveFormat = "0.##¤"
      negativeFormat = "-0.##¤"
    default:
      break
    }
  }
}
