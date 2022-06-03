import CUtility

public protocol JSONValueProtocol: JSONObjectProtocol, CustomStringConvertible, Equatable where Value == Self {

  associatedtype Array where Array: Collection, Array.Element == Self

  associatedtype Object where Object: Sequence, Object.Element == (key: Self, value: Self), Object: JSONObjectProtocol, Object.Value == Self

  // MARK: JSON Pointer
  func value(withPointer pointer: String) -> Self

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

  var bool: Bool? { get }

  var uint64: UInt64? { get }

  var int64: Int64? { get }

  var double: Double? { get }

  func withRawCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T?

  func withCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T?

}

public extension JSONValueProtocol {

  @inlinable
  subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> Value? {
    object?[keyBuffer]
  }

  @inlinable
  var rawString: String? {
    withRawCStringIfAvailable(String.init)
  }

  @inlinable
  var string: String? {
    withCStringIfAvailable(String.init)
  }

  @inline(never)
  var description: String {
    if isString {
      return string!
    }
    if isBool {
      return bool!.description
    }
    if isUnsignedInteger {
      return uint64!.description
    }
    if isSignedInteger {
      return int64!.description
    }
    if isArray {
      return ContiguousArray(array!).description
    }
    if isObject {
      return ContiguousArray(object!).description
    }
    if isRaw {
      return rawString!
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
