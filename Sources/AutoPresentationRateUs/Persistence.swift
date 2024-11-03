import DuckUserSettings

extension UserSettingsClient {
  var rateUsPresentationSession: Int? {
    dataForKey(.rateUsPresentationSession)
      .flatMap { String(data: $0, encoding: .utf8) }
      .flatMap(Int.init)
  }

  func setRateUsPresentationSession(_ newValue: Int?) async {
    if let newValue {
      await setData("\(newValue)".data(using: .utf8), .rateUsPresentationSession)
    } else {
      await setData(nil, .rateUsPresentationSession)
    }
  }

  var rateUsImpressionCount: Int? {
    dataForKey(.rateUsImpressionCount)
      .flatMap { String(data: $0, encoding: .utf8) }
      .flatMap(Int.init)
  }

  func setRateUsImpressionCount(_ newValue: Int?) async {
    if let newValue {
      await setData("\(newValue)".data(using: .utf8), .rateUsImpressionCount)
    } else {
      await setData(nil, .rateUsImpressionCount)
    }
  }
}

private extension String {
  static var rateUsPresentationSession: String { "auto-presentation.rate-us.presentation-session" }
  static var rateUsImpressionCount: String { "auto-presentation.rate-us.impression-count" }
}
