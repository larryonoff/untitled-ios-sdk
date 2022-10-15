import Amplitude
import Foundation
import FoundationSupport
import ComposableArchitecture

extension AmplitudeClient {
  public static let live = AmplitudeClient(
    initialize: {
      await MainActor.run {
        let bundle = Bundle.main

        guard let apiKey = bundle.amplitudeAPIKey else {
          assertionFailure()
          return
        }

        let amplitude = Amplitude.instance()
        amplitude.trackingSessionEvents = true
        amplitude.initializeApiKey(apiKey)
      }
    }
  )
}
