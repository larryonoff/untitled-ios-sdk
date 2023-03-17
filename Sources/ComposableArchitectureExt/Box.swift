@dynamicMemberLookup
@propertyWrapper
public struct Box<RawValue> {
  /// The unchecked value.
  public var value: RawValue

  public init(_ value: RawValue) {
    self.value = value
  }

  public init(wrappedValue: RawValue) {
    self.value = wrappedValue
  }

  public var wrappedValue: RawValue {
    _read { yield self.value }
    _modify { yield &self.value }
  }

  public var projectedValue: Self {
    get { self }
    set { self = newValue }
  }

  public subscript<Subject>(dynamicMember keyPath: KeyPath<RawValue, Subject>) -> Subject {
    wrappedValue[keyPath: keyPath]
  }

  public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<RawValue, Subject>) -> Subject {
    _read { yield self.value[keyPath: keyPath] }
    _modify { yield &self.value[keyPath: keyPath] }
  }
}

extension Box: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
    wrappedValue
  }
}

extension Box: Collection where RawValue: Collection {
  public typealias Element = RawValue.Element
  public typealias Index = RawValue.Index

  public func index(after i: RawValue.Index) -> RawValue.Index {
    wrappedValue.index(after: i)
  }

  public subscript(position: RawValue.Index) -> RawValue.Element {
    wrappedValue[position]
  }

  public var startIndex: RawValue.Index {
    wrappedValue.startIndex
  }

  public var endIndex: RawValue.Index {
    wrappedValue.endIndex
  }

  public __consuming func makeIterator() -> RawValue.Iterator {
    wrappedValue.makeIterator()
  }
}

extension Box: Comparable where RawValue: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue < rhs.wrappedValue
  }
}
extension Box: Decodable where RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      self.init(try decoder.singleValueContainer().decode(RawValue.self))
    } catch {
      self.init(try .init(from: decoder))
    }
  }
}

extension Box: Encodable where RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    do {
      var container = encoder.singleValueContainer()
      try container.encode(wrappedValue)
    } catch {
      try wrappedValue.encode(to: encoder)
    }
  }
}

extension Box: Equatable where RawValue: Equatable {
  public static func == (lhs: Box<Self>, rhs: Box<Self>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Box: Hashable where RawValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension Box: Sendable where RawValue: Sendable {}

extension Box: Sequence where RawValue: Sequence {
  public typealias Iterator = RawValue.Iterator

  public __consuming func makeIterator() -> RawValue.Iterator {
    wrappedValue.makeIterator()
  }
}
