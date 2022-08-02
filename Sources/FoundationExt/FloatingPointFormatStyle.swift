import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle {
  public struct Duration: Codable, Hashable {
    public var locale: Locale

    public init(locale: Locale = .autoupdatingCurrent) {
      self.locale = locale
    }
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FloatingPointFormatStyle.Duration: Foundation.FormatStyle {
  public func format(_ value: Value) -> String {
    let valueFormat = String(format: "%.1f", TimeInterval(value))
    return "\(valueFormat)s"
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Foundation.FormatStyle
where Self == FloatingPointFormatStyle<Double>.Duration {
  public static var duration: Self { .init() }
}

private let durationFormatter: DateComponentsFormatter = {
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.second]
  formatter.allowsFractionalUnits = true
  formatter.unitsStyle = .abbreviated
  return formatter
}()
