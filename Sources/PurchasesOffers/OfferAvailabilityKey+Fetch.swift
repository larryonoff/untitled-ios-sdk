import Dependencies
import DuckPaywallTargeting
import DuckPurchasesClient
import DuckPurchasesCore
import DuckRemoteSettingsClient
import Foundation
import IssueReporting
import OSLog

extension OfferAvailabilityKey {
  func fetch() async -> OfferAvailability {
    do {
      try await remoteSettings.fetch(.request())
    } catch {
      // Expected offline; the last activated values still apply.
      logger.info("offers.availability remote-settings-fetch-failed | error: \(error.localizedDescription, privacy: .public)")
    }

    async let introductory = introductoryStatus()
    async let special = specialStatus()

    let availability = await OfferAvailability(
      introductory: introductory,
      special: special
    )

    logger.info(
      "offers.availability | introductory: \(availability.introductory.name, privacy: .public), special: \(availability.special.name, privacy: .public)"
    )

    return availability
  }

  private func introductoryStatus() async -> OfferAvailability.Status<Product.EligibleSubscriptionOffer> {
    guard remoteSettings.isIntroductoryOfferEnabled else { return .unavailable }

    let paywall: Paywall?
    do {
      paywall = try await purchases.latestPaywall(
        byID: paywallTargeting.paywall(forKind: .Offer.introductory).id
      )
    } catch {
      return .unknown
    }

    // Adapty attaches an introductory offer only when the user is eligible.
    guard
      let offer = paywall?.eligibleOffers.first(where: { $0.offer.type == .introductory })
    else {
      return .unavailable
    }

    return .available(offer)
  }

  private func specialStatus() async -> OfferAvailability.Status<SpecialOffer> {
    // A seasonal offer when remote config picks one and its campaign hasn't
    // ended, otherwise the limited-time offer unless it's switched off. A
    // campaign left in remote config after its end date would otherwise hold
    // the limited-time offer back for good.
    if let seasonal = remoteSettings.paywallSpecialOffer {
      let status = await specialStatus(of: seasonal)
      guard
        case let .available(offer) = status,
        case let .at(endDate) = offer.expiration,
        endDate <= date.now
      else {
        return status
      }
      logger.info("offers.availability seasonal-offer-ended | kind: \(seasonal.rawValue, privacy: .public)")
    }

    guard remoteSettings.isLimitedTimeOfferEnabled else { return .unavailable }
    return await specialStatus(of: .Offer.limitedTime)
  }

  private func specialStatus(of kind: Paywall.Kind) async -> OfferAvailability.Status<SpecialOffer> {
    let paywall: Paywall?
    do {
      paywall = try await purchases.latestPaywall(
        byID: paywallTargeting.paywall(forKind: kind).id
      )
    } catch {
      return .unknown
    }

    guard let paywall, let offer = paywall.eligibleOffers.first else {
      return .unavailable
    }

    // Adapty attaches promotional offers without checking eligibility, so
    // unless promos are enabled the offer must be an introductory one.
    guard
      remoteSettings.isPromoOfferEnabled || offer.offer.type == .introductory
    else {
      return .unavailable
    }

    let expiration: SpecialOffer.Expiration
    if let endDate = paywall.offerEndDate {
      expiration = .at(endDate)
    } else if let duration = paywall.offerDuration, duration > 0 {
      expiration = .afterFirstShown(duration)
    } else {
      reportIssue(
        "Special-offer paywall \(paywall.id) has neither 'offer_end_date' nor a positive 'offer_duration'."
      )
      return .unavailable
    }

    return .available(.init(kind: kind, discount: offer.discount, expiration: expiration))
  }
}

private extension OfferAvailability.Status {
  var name: String {
    switch self {
    case .available: "available"
    case .unavailable: "unavailable"
    case .unknown: "unknown"
    }
  }
}
