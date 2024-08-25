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

  var rateUsSaveOrShareCount: Int? {
    dataForKey(.rateUsSaveOrShareCount)
      .flatMap { String(data: $0, encoding: .utf8) }
      .flatMap(Int.init)
  }

  func setRateUsSaveOrShareCount(_ newValue: Int?) async {
    if let newValue {
      await setData("\(newValue)".data(using: .utf8), .rateUsSaveOrShareCount)
    } else {
      await setData(nil, .rateUsSaveOrShareCount)
    }
  }
}

private extension String {
  static let rateUsPresentationSession = "auto-presentation.rate-us.presentation-session"
  static let rateUsSaveOrShareCount = "auto-presentation.rate-us.save-share-count"
}
