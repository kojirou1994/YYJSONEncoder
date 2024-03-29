import CUtility

public protocol JSONValueProtocol: CustomStringConvertible, Equatable {

  associatedtype Array: JSONArrayProtocol where Array.RawValue == Self

  associatedtype Object: JSONObjectProtocol where Object.RawValue == Self

  // MARK: Value API
  var typeDescription: StaticCString { get }

  // MARK: Value Type API
  var isRaw: Bool { get }

  var isNull: Bool { get }

  var isTrue: Bool { get }

  var isFalse: Bool { get }

  var isBool: Bool { get }

  var isUnsignedInteger: Bool { get }

  var isSignedInteger: Bool { get }

  var isInteger: Bool { get }

  var isDouble: Bool { get }

  var isNumber: Bool { get }

  var isString: Bool { get }

  var isArray: Bool { get }

  var isObject: Bool { get }

  var isContainer: Bool { get }

  // MARK: Unsafe Value Getter/Setter
  func unsafeSetNull()

  var unsafeBool: Bool { get nonmutating set }

  var unsafeUInt64: UInt64 { get nonmutating set }

  var unsafeInt64: Int64 { get nonmutating set }

  var unsafeDouble: Double { get nonmutating set }

  /// convert and return any number value as double
  var unsafeNumber: Double { get }

  var unsafeRaw: UnsafePointer<CChar> { get }

  var unsafeString: UnsafePointer<CChar> { get }

  /// Returns the content length (string length in bytes, array size,
  /// object size), or 0 if the value does not contains length data.
  var length: Int { get }

  func equals(toString buffer: UnsafeRawBufferPointer) -> Bool

}

public extension JSONValueProtocol {

  @inlinable
  subscript(key: some ContiguousUTF8Bytes) -> Self? {
    object?[key]
  }

  @inlinable
  subscript(index: Int) -> Self? {
    array?.value(at: index)
  }

  // MARK: Safe Value Getter

  @inlinable
  var bool: Bool? {
    isBool ? unsafeBool : nil
  }

  @inlinable
  var uint64: UInt64? {
    isUnsignedInteger ? unsafeUInt64 : nil
  }

  @inlinable
  var int64: Int64? {
    isSignedInteger ? unsafeInt64 : nil
  }

  @inlinable
  var double: Double? {
    isDouble ? unsafeDouble : nil
  }

  @inlinable
  var number: Double? {
    isNumber ? unsafeNumber : nil
  }

  @inlinable
  func withUnsafeRawIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    isRaw ? try body(unsafeRaw) : nil
  }

  @inlinable
  func withUnsafeStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    isString ? try body(unsafeString) : nil
  }

  @inlinable
  func withUnsafeRawBufferIfAvailable<T>(_ body: (UnsafeRawBufferPointer) throws -> T) rethrows -> T? {
    isRaw ? try body(.init(start: unsafeRaw, count: length)) : nil
  }

  @inlinable
  func withUnsafeStringBufferIfAvailable<T>(_ body: (UnsafeRawBufferPointer) throws -> T) rethrows -> T? {
    isString ? try body(.init(start: unsafeString, count: length)) : nil
  }

  /// copied raw
  @inlinable
  var raw: String? {
    withUnsafeRawBufferIfAvailable { String(decoding: $0, as: UTF8.self) }
  }

  /// copied string
  @inlinable
  var string: String? {
    withUnsafeStringBufferIfAvailable { String(decoding: $0, as: UTF8.self) }
  }

  /// array representation
  @inlinable
  var array: Array? {
    .init(rawValue: self)
  }

  /// object representation
  @inlinable
  var object: Object? {
    .init(rawValue: self)
  }

  @inline(never)
  var description: String {
    if let string = string {
      return string
    }
    if let bool = bool {
      return bool.description
    }
    if let uint64 = uint64 {
      return uint64.description
    }
    if let int64 = int64 {
      return int64.description
    }
    if let array = array {
      return ContiguousArray(array).description
    }
    if let object = object {
      return ContiguousArray(object).description
    }
    if let raw = raw {
      return raw
    }
    if isNull {
      return "Null"
    }
    assertionFailure("unknown type?")
    return "Unknown"
  }
}

public protocol MutableJSONValueProtocol: JSONValueProtocol where Array: MutableCollection, Array: RangeReplaceableCollection {

}

// MARK: equal operators
public extension JSONValueProtocol {
  @inlinable
  static func == (lhs: Self, rhs: Bool) -> Bool {
    lhs.isBool && lhs.unsafeBool == rhs
  }

  @inlinable
  static func == (lhs: Self, rhs: UInt64) -> Bool {
    lhs.isUnsignedInteger && lhs.unsafeUInt64 == rhs
  }

  @inlinable
  static func == (lhs: Self, rhs: Int64) -> Bool {
    lhs.isSignedInteger && lhs.unsafeInt64 == rhs
  }

  @inlinable
  static func == (lhs: Self, rhs: Double) -> Bool {
    lhs.isDouble && lhs.unsafeDouble == rhs
  }

  @inlinable
  static func == (value: Self, string: some ContiguousUTF8Bytes) -> Bool {
    string.withContiguousUTF8Bytes(value.equals(toString:))
  }
}

// MARK: number convertion
public extension JSONValueProtocol {
  /// return nil if value is not number or number overflows
  func numberToInteger<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
    if isSignedInteger {
      return .init(exactly: unsafeInt64)
    }
    if isUnsignedInteger {
      return .init(exactly: unsafeUInt64)
    }
    if isDouble {
      return .init(exactly: unsafeDouble)
    }
    return nil
  }

  /// return nil if value is not number
  @available(*, deprecated, message: "use number getter")
  func numberToDouble() -> Double? {
    if isSignedInteger {
      return .init(unsafeInt64)
    }
    if isUnsignedInteger {
      return .init(unsafeUInt64)
    }
    if isDouble {
      return unsafeDouble
    }
    return nil
  }
}
