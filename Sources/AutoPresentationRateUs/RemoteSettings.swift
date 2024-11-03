import ComposableArchitecture
import DuckRemoteSettingsClient
import DuckRemoteSettingsComposable

extension RemoteSettingsClient {
  public var isRateUsEnabled: Bool {
    boolForKey(.rateUsEnabled) ?? Default.rateUsEnabled
  }

  public var rateUsSessionsDelay: Int {
    integerForKey(.rateUsSessionsDelay) ?? Default.rateUsSessionsDelay
  }

  public var rateUsStartSession: Int {
    integerForKey(.rateUsStartSession) ?? Default.rateUsStartSession
  }
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<RemoteSettingKey<Bool>> {
  public static var isRateUsEnabled: Self {
    PersistenceKeyDefault(.remoteSetting(.rateUsEnabled), Default.rateUsEnabled)
  }
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<RemoteSettingKey<Int>> {
  public static var rateUsSessionsDelay: Self {
    PersistenceKeyDefault(.remoteSetting(.rateUsSessionsDelay), Default.rateUsSessionsDelay)
  }
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<RemoteSettingKey<Int>> {
  public static var rateUsStartSession: Self {
    PersistenceKeyDefault(.remoteSetting(.rateUsStartSession), Default.rateUsStartSession)
  }
}

private enum Default {
  static var rateUsEnabled: Bool { true }
  static var rateUsSessionsDelay: Int { 15 }
  static var rateUsStartSession: Int { 2 }
}

private extension String {
  static var rateUsEnabled: String { "rate_us_enabled" }
  static var rateUsSessionsDelay: String { "rate_us_sessions_delay" }
  static var rateUsStartSession: String { "rate_us_start_session" }
}
