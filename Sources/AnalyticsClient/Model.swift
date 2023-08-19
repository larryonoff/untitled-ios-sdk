import Tagged

extension AnalyticsClient {
  public typealias EventName = Tagged<(AnalyticsClient, evenName: ()), String>
  public typealias EventParameterName = Tagged<(AnalyticsClient, parameterName: ()), String>
  public typealias UserPropertyName = Tagged<(AnalyticsClient, userProperty: ()), String>
}
