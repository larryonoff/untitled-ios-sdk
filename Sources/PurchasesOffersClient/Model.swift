import CasePaths
import DuckPurchasesCore
import Foundation

public enum PurchasesOfferType: Codable, Equatable, Hashable, Sendable {
  case blackFriday
  case limitedTime
  case introductory

  public var paywallType: Paywall.PaywallType {
    switch self {
    case .blackFriday: .Offer.blackFriday
    case .limitedTime: .Offer.limitedTime
    case .introductory: .Offer.introductory
    }
  }
}

@CasePathable
@dynamicMemberLookup
public enum PurchasesOffer: Codable, Equatable, Hashable, Sendable {
  public struct BlackFriday: Codable, Equatable, Hashable, Sendable {
    public var discount: Decimal

    // start date is nil until first closing of paywall
    public var startDate: Date?
    public var endDate: Date

    public func isValid(for date: Date) -> Bool {
      endDate > date
    }
  }

  public struct LimitedTime: Codable, Equatable, Hashable, Sendable {
    public var discount: Decimal

    // start date is nil until first closing of paywall
    public var startDate: Date?

    public var endDate: Date? {
      startDate?.addingTimeInterval(duration)
    }

    public var duration: TimeInterval

    public func isValid(for date: Date) -> Bool {
      guard let endDate else { return true }
      return endDate > date
    }
  }

  case blackFriday(BlackFriday)
  case introductory
  case limitedTime(LimitedTime)

  public var paywallType: Paywall.PaywallType {
    switch self {
    case .blackFriday: .Offer.blackFriday
    case .limitedTime: .Offer.limitedTime
    case .introductory: .Offer.introductory
    }
  }

  public var endDate: Date? {
    switch self {
    case let .blackFriday(offer): offer.endDate
    case let .limitedTime(offer): offer.endDate
    case .introductory: nil
    }
  }

  public func isValid(for date: Date) -> Bool {
    switch self {
    case let .blackFriday(offer): offer.isValid(for: date)
    case .introductory: true
    case let .limitedTime(offer): offer.isValid(for: date)
    }
  }
}
