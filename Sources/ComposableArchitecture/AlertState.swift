import ComposableArchitecture

extension AlertState {
  public static func failure(
    _ error: any Swift.Error,
    action: Action? = nil
  ) -> Self {
    AlertState {
      TextState(error.localizedDescription)
    } actions: {
      ButtonState(role: .cancel, action: .send(action)) {
        TextState("OK")
      }
    }
  }
}
