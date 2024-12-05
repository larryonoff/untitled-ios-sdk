import ComposableArchitecture
import DuckRemoteSettingsClient
import DuckRemoteSettingsComposable

extension RemoteSettingsClient {
  public var isRateUsEnabled: Bool {
    boolForKey(.rateUsEnabled) ?? _Default.rateUsEnabled
  }

  public var rateUsSessionsDelay: Int {
    integerForKey(.rateUsSessionsDelay) ?? _Default.rateUsSessionsDelay
  }

  public var rateUsStartSession: Int {
    integerForKey(.rateUsStartSession) ?? _Default.rateUsStartSession
  }
}

extension SharedReaderKey where Self == RemoteSettingKey<Bool>.Default {
  public static var isRateUsEnabled: Self {
    Self[.remoteSetting(.rateUsEnabled), default: _Default.rateUsEnabled]
  }
}

extension SharedReaderKey where Self == RemoteSettingKey<Int>.Default {
  public static var rateUsSessionsDelay: Self {
    Self[.remoteSetting(.rateUsSessionsDelay), default: _Default.rateUsSessionsDelay]
  }
}

extension SharedReaderKey where Self == RemoteSettingKey<Int>.Default {
  public static var rateUsStartSession: Self {
    Self[.remoteSetting(.rateUsStartSession), default: _Default.rateUsStartSession]
  }
}

private enum _Default {
  static var rateUsEnabled: Bool { true }
  static var rateUsSessionsDelay: Int { 15 }
  static var rateUsStartSession: Int { 2 }
}

private extension String {
  static var rateUsEnabled: String { "rate_us_enabled" }
  static var rateUsSessionsDelay: String { "rate_us_sessions_delay" }
  static var rateUsStartSession: String { "rate_us_start_session" }
}
