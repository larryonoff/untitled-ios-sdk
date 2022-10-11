import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PurchasesClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = PurchasesClient(
    initialize: XCTUnimplemented("\(Self.self).initialize"),
    paywalByID: XCTUnimplemented("\(Self.self).paywalByID", placeholder: nil),
    purchase: XCTUnimplemented("\(Self.self).purchase", placeholder: .userCancelled),
    purchases: XCTUnimplemented("\(Self.self).purchases", placeholder: Purchases()),
    purchasesUpdates: XCTUnimplemented("\(Self.self).purchasesUpdates", placeholder: .finished),
    restorePurhases: XCTUnimplemented("\(Self.self).restorePurhases", placeholder: .userCancelled),
    logPaywall: XCTUnimplemented("\(Self.self).logPaywall")
  )
}

extension PurchasesClient {
  public static let noop = PurchasesClient(
    initialize: {},
    paywalByID: { _ in try await Task.never() },
    purchase: { _ in try await Task.never() },
    purchases: { Purchases() },
    purchasesUpdates: { AsyncStream { _ in } },
    restorePurhases: { try await Task.never() },
    logPaywall: { _ in try await Task.never() }
  )
}
