#if os(iOS)

import ComposableArchitecture
import UIKit

extension ApplicationClient: DependencyKey {}

extension ApplicationClient {
  public static let liveValue: Self = {
    Self(
      isIdleTimerDisabled: {
        await UIApplication.shared.isIdleTimerDisabled
      },
      setIdleTimerDisabled: { newValue in
        await MainActor.run {
          UIApplication.shared.isIdleTimerDisabled = newValue
        }
      }
    )
  }()
}

#endif
