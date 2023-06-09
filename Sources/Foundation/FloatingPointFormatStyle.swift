import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle {
  public struct Duration: Codable, Hashable {
    var locale: Locale
    var minIntegerDigits: UInt
    var minFractionDigits: UInt

    public init(
      locale: Locale = .autoupdatingCurrent,
      minIntegerDigits: UInt = 0,
      minFractionDigits: UInt = 1
    ) {
      self.locale = locale
      self.minIntegerDigits = minIntegerDigits
      self.minFractionDigits = minFractionDigits
    }
  }

  public struct Timer: Codable, Hashable {
    var locale: Locale

    public init(
      locale: Locale = .autoupdatingCurrent
    ) {
      self.locale = locale
    }
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle.Duration: Foundation.FormatStyle {
  public func format(_ value: Value) -> String {
    var format = "%"
    format += "\(minIntegerDigits > 0 ? "\(minIntegerDigits)" : "")"
    format += "."
    format += "\(minFractionDigits > 0 ? "\(minFractionDigits)" : "")"
    format += "f"

    let valueString = String(format: format, TimeInterval(value))
    return "\(valueString)s"
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle.Timer: Foundation.FormatStyle {
  public func format(_ value: Value) -> String {
    let minutes = Int(value) / 60 % 60
    let seconds = Int(value) % 60
    let milliseconds = Int(value * 10) % 10
    return String(
      format:"%02i:%02i,%02i",
      minutes,
      seconds,
      milliseconds
    )
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.FormatStyle
  where Self == FloatingPointFormatStyle<Double>.Duration
{
  public static func duration(
    minIntegerDigits: UInt = 0,
    minFractionDigits: UInt = 1
  ) -> Self {
    .init(
      minIntegerDigits: minIntegerDigits,
      minFractionDigits: minFractionDigits
    )
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.FormatStyle
  where Self == FloatingPointFormatStyle<Double>.Timer
{
  public static func timer() -> Self {
    .init()
  }
}
