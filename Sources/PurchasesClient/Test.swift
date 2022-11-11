import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PurchasesClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = PurchasesClient(
    initialize: unimplemented("\(Self.self).initialize"),
    paywalByID: unimplemented("\(Self.self).paywalByID", placeholder: nil),
    purchase: unimplemented("\(Self.self).purchase", placeholder: .userCancelled),
    purchases: unimplemented("\(Self.self).purchases", placeholder: Purchases()),
    purchasesUpdates: unimplemented("\(Self.self).purchasesUpdates", placeholder: .finished),
    restorePurhases: unimplemented("\(Self.self).restorePurhases", placeholder: .userCancelled),
    logPaywall: unimplemented("\(Self.self).logPaywall")
  )
}

extension PurchasesClient {
  public static let noop = PurchasesClient(
    initialize: { try await Task.never() },
    paywalByID: { _ in try await Task.never() },
    purchase: { _ in try await Task.never() },
    purchases: { Purchases() },
    purchasesUpdates: { AsyncStream { _ in } },
    restorePurhases: { try await Task.never() },
    logPaywall: { _ in try await Task.never() }
  )
}
