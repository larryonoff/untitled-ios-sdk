public enum PresentationAction<Action> {
   case dismiss

   indirect case presented(Action)
 }

 extension PresentationAction: Equatable where Action: Equatable {}
 extension PresentationAction: Hashable where Action: Hashable {}
 extension PresentationAction: Sendable where Action: Sendable {}
 extension PresentationAction: Decodable where Action: Decodable {}
 extension PresentationAction: Encodable where Action: Encodable {}
