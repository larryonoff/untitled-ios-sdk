import Foundation
import Sharing

extension SharedKey where Self == AppStorageKey<Bool>.Default {
  public static var isOnboardingCompleted: Self {
    Self[.appStorage(.isOnboardingCompletedKey), default: false]
  }
}

extension String {
  public static var isOnboardingCompletedKey: Self { "onboarding-completed" }
}
