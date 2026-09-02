extension Connectivity {
  /// Whether the network path is available to establish connections.
  ///
  /// - Warning: Deprecated. This now mirrors `NWPath.Status` and reports whether a
  ///   network path exists — it no longer performs an HTTP reachability probe. A flaky
  ///   proxy on the local network can no longer produce a false negative. Prefer
  ///   matching on ``status`` directly.
  @available(*, deprecated, message: "Use `status == .satisfied`.")
  public var isConnected: Bool {
    status == .satisfied
  }
}
