import DuckAutoPresentationClient

extension AutoPresentation.Event {
  public enum RateUs {
    public static let impression: AutoPresentation.Event = "rate-us.impression"
  }
}

extension AutoPresentation.Feature {
  public static let rateUs: Self = "rate_us"
}
