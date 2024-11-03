import DuckAnalyticsClient

extension AnalyticsClient.EventName {
  static var idfaResponse: Self { "idfa_permission_response" }
  static var idfaRequest: Self { "idfa_permission_request" }
}

extension AnalyticsClient.EventParameterName {
  static var status: Self { "status" }
}
