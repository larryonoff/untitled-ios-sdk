import Amplitude
import Foundation
import FoundationSupport
import UserIdentifier
import LoggingSupport
import OSLog

extension AmplitudeClient {
  public static func live(
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    let impl = AmplitudeClientImpl(
      userIdentifier: userIdentifier
    )

    return Self(
      initialize: {
        impl.initialize()
      },
      deviceID: {
        Amplitude.instance().deviceId
      },
      reset: {
        impl.reset()
      }
    )
  }
}

final class AmplitudeClientImpl {
  private let userIdentifier: UserIdentifierGenerator

  init(
    userIdentifier: UserIdentifierGenerator
  ) {
    self.userIdentifier = userIdentifier
  }

  func initialize() {
    logger.info("initialize")

    let bundle = Bundle.main

    guard let apiKey = bundle.amplitudeAPIKey else {
      assertionFailure()
      return
    }

    let amplitude = Amplitude.instance()
    amplitude.trackingSessionEvents = true
    amplitude.initializeApiKey(
      apiKey,
      userId: userIdentifier().uuidString
    )

    logger.info("initialize success")
  }

  func reset() {
    Amplitude.instance()
      .setUserId(userIdentifier().uuidString)
  }
}

private let logger = Logger(
  subsystem: ".SDK.amplitude",
  category: "Amplitude"
)
