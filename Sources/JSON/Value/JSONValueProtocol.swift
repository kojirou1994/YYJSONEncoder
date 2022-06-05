import CUtility

public protocol JSONValueProtocol: JSONObjectProtocol, CustomStringConvertible, Equatable where Value == Self {

  associatedtype Array where Array: Collection, Array.Element == Self, Array.Index == Int

  associatedtype Object where Object: Sequence, Object.Element == (key: Self, value: Self), Object: JSONObjectProtocol, Object.Value == Self

  // MARK: JSON Pointer
  func value(withPointer pointer: UnsafePointer<CChar>) -> Self?

  // MARK: Array API
  subscript(index: Int) -> Self? { get }
  var array: Array? { get }

  // MARK: Object API
  var object: Object? { get }

  // MARK: Value API
  var typeDescription: StaticCString { get }

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

  var unsafeBool: Bool { get }

  var unsafeUInt64: UInt64 { get }

  var unsafeInt64: Int64 { get }

  var unsafeDouble: Double { get }

  var unsafeRaw: UnsafePointer<CChar> { get }

  var unsafeString: UnsafePointer<CChar> { get }

  func equals(toString buffer: UnsafeRawBufferPointer) -> Bool

}

public extension JSONValueProtocol {

  @inlinable
  subscript(keyBuffer: UnsafeRawBufferPointer) -> Value? {
    object?[keyBuffer]
  }

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
  func withUnsafeRawIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    isRaw ? try body(unsafeRaw) : nil
  }

  @inlinable
  func withUnsafeStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    isString ? try body(unsafeString) : nil
  }

  @inlinable
  var raw: String? {
    withUnsafeRawIfAvailable(String.init)
  }

  @inlinable
  var string: String? {
    withUnsafeStringIfAvailable(String.init)
  }

  @inlinable
  static func == <T: StringProtocol> (value: Self, string: T) -> Bool {
    string.withCStringBuffer { value.equals(toString: .init($0)) }
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

public protocol MutableJSONValueProtocol: JSONValueProtocol where Array: MutableCollection {

}
