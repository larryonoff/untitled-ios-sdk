import Foundation

extension FloatingPointFormatStyle {
  public struct Duration: Codable, Hashable {
    public enum UnitWidth: Codable, Hashable {
      case narrow
      case ommited
    }

    public var locale: Locale
    public var minIntegerDigits: UInt
    public var minFractionDigits: UInt
    public var width: UnitWidth

    public init(
      locale: Locale = .autoupdatingCurrent,
      minIntegerDigits: UInt = 0,
      minFractionDigits: UInt = 1,
      width: UnitWidth = .narrow
    ) {
      self.locale = locale
      self.minIntegerDigits = minIntegerDigits
      self.minFractionDigits = minFractionDigits
      self.width = width
    }

    public func width(_ width: UnitWidth) -> Self {
      modify { $0.width = width }
    }

    func modify(
      _ transform: (inout Self) throws -> Void
    ) rethrows -> Self {
      var new = self
      try transform(&new)
      return new
    }
  }

  public struct Timer: Codable, Hashable {
    public var locale: Locale

    public init(
      locale: Locale = .autoupdatingCurrent
    ) {
      self.locale = locale
    }
  }
}

extension FloatingPointFormatStyle.Duration: Foundation.FormatStyle {
  public func format(_ value: Value) -> String {
    var format = "%"
    format += "\(minIntegerDigits > 0 ? "\(minIntegerDigits)" : "")"
    format += "."
    format += "\(minFractionDigits > 0 ? "\(minFractionDigits)" : "")"
    format += "f"

    let string = String(format: format, TimeInterval(value))

    switch width {
    case .narrow:
      return "\(string)s"
    case .ommited:
      return string
    }
  }
}

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

  public static var duration: Self {
    self.duration()
  }
}

extension Foundation.FormatStyle
  where Self == FloatingPointFormatStyle<Double>.Timer
{
  public static var timer: Self {
    .init()
  }
}
