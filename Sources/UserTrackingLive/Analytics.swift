import DuckAnalyticsClient

extension AnalyticsClient.EventName {
  static let idfaRequest: Self = "idfa_permission_request"
  static let idfaResponse: Self = "idfa_permission_response"
}

extension AnalyticsClient.EventParameterName {
  static let status: Self = "status"
}
