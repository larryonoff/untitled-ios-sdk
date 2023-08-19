import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import UserIdentifier
import LoggingSupport
import OSLog

extension FirebaseClient {
  public static func live(
    userIdentifier: UserIdentifierGenerator
  ) -> FirebaseClient {
    let impl = FirebaseClientImpl(
      userIdentifier: userIdentifier
    )

    return Self(
      initialize: {
        impl.initialize()
      },
      recordError: { error, userInfo in
        impl.record(error, userInfo: userInfo)
      },
      reset: {
        impl.reset()
      }
    )
  }
}

final class FirebaseClientImpl {
  private let userIdentifier: UserIdentifierGenerator

  init(
    userIdentifier: UserIdentifierGenerator
  ) {
    self.userIdentifier = userIdentifier
  }

  func initialize(
  ) {
    logger.info("initialize")

    FirebaseApp.configure()

    #if DEBUG
    let crashlytics = Crashlytics.crashlytics()
    crashlytics.setCrashlyticsCollectionEnabled(false)
    #endif

    updateUserID()

    logger.info("initialize success")
  }

  func record(_ error: Error, userInfo: [String: Any]?) {
    Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
  }

  func updateUserID() {
    let userID = userIdentifier()
    FirebaseAnalytics.Analytics.setUserID(userID.uuidString)
    Crashlytics.crashlytics().setUserID(userID.uuidString)
  }

  func reset() {
    updateUserID()
  }
}

private let logger = Logger(
  subsystem: ".SDK.firebase",
  category: "Firebase"
)
