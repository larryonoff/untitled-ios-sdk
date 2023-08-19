import DuckAnalyticsClient

extension AnalyticsClient.EventName {
  static let idfaResponse: Self = "idfa_permission_response"
  static let idfaRequest: Self = "idfa_permission_request"
}

extension AnalyticsClient.EventParameterName {
  static let status: Self = "status"
}
