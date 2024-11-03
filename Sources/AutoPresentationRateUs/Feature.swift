import DuckAutoPresentationClient

extension AutoPresentation.Event {
  public enum RateUs {
    public static var impression: AutoPresentation.Event { "rate-us.impression" }
  }
}

extension AutoPresentation.Feature {
  public static var rateUs: Self { "rate_us" }
}
