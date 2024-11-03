import ComposableArchitecture
import Foundation

extension PersistenceKey where Self == PersistenceKeyDefault<AppStorageKey<Bool>> {
  public static var isOnboardingCompleted: Self {
    PersistenceKeyDefault(.appStorage(.isOnboardingCompletedKey), false)
  }
}

extension String {
  public static var isOnboardingCompletedKey: Self { "onboarding-completed" }
}
