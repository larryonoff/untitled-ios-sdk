import ComposableArchitecture

extension AlertState {
  public static func failure(_ error: Swift.Error) -> Self {
    AlertState {
      TextState(error.localizedDescription)
    } actions: {
      ButtonState(role: .cancel) {
        TextState("OK")
      }
    }
  }
}
