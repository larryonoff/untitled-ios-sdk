import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import ComposableArchitecture
import UserIdentifier
import LoggingSupport
import os.log

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

  func updateUserID() {
    let userID = userIdentifier()
    FirebaseAnalytics.Analytics.setUserID(userID.uuidString)
    Crashlytics.crashlytics().setUserID(userID.uuidString)
  }
}

private let logger = Logger(
  subsystem: ".SDK.firebase",
  category: "Firebase"
)
