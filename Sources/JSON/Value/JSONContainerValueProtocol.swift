public protocol JSONContainerValueProtocol: RawRepresentable, Sequence where RawValue: JSONValueProtocol, Iterator: JSONContainerIterator {
}

public protocol JSONArrayProtocol: JSONContainerValueProtocol, RandomAccessCollection where Element == RawValue, Index == Int {
  func value(at idx: Index) -> Element?
}

public extension JSONArrayProtocol {

  @inlinable
  var count: Int { rawValue.length }

  @inlinable
  var startIndex: Int { 0 }

  @inlinable
  var endIndex: Int { count }

  @inlinable
  func index(after i: Int) -> Int { i + 1 }

  @inlinable
  func index(before i: Index) -> Index { i - 1 }
}

public protocol JSONContainerIterator: IteratorProtocol {
  var hasNext: Bool { get }
  mutating func reset()
}

/// sequence's element is object key
public protocol JSONObjectProtocol: JSONContainerValueProtocol, Sequence where Element == RawValue, Iterator: JSONObjectIterator {
  typealias Key = RawValue
  typealias Value = RawValue
  func value(for keyBuffer: UnsafeRawBufferPointer) -> Value?
}

public extension JSONObjectProtocol {
  @inlinable
  subscript(key: some StringProtocol) -> Value? {
    key.withCStringBuffer(value(for:))
  }
}

public protocol JSONObjectIterator: JSONContainerIterator {
  /// Returns the value for key inside the iteration.
  /// - Parameter key: key retuened from next()
  /// - Returns: the value
  func value(for key: Element) -> Element

  /// Iterates to a specified key and returns the value.
  mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> Element?
}

public extension JSONObjectIterator {
  mutating func nextKeyValue() -> (key: Element, value: Element)? {
    next().map { ($0, value(for: $0)) }
  }
}
