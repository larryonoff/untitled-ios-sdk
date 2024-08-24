import DuckUserSettings

extension UserSettingsClient {
  var autoPresentationSessionID: Int? {
    dataForKey(.autoPresentationSession)
      .flatMap { String(data: $0, encoding: .utf8) }
      .flatMap(Int.init)
  }

  func setAutoPresentationSession(_ newValue: Int?) async {
    if let newValue {
      await setData("\(newValue)".data(using: .utf8), .autoPresentationSession)
    } else {
      await setData(nil, .autoPresentationSession)
    }
  }
}

private extension String {
  static let autoPresentationSession = ".sdk.auto-presentation-session"
}
