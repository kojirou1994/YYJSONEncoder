import CUtility

public protocol JSONValueProtocol: CustomStringConvertible, Equatable {

  associatedtype Array where Array: Collection, Array.Element == Self

  associatedtype Object where Object: Sequence, Object.Element == (key: Self, value: Self)

  // MARK: JSON Pointer
  func value(withPointer pointer: String) -> Self

  // MARK: Array API
  subscript(index: Int) -> Self? { get }
  var array: Array? { get }

  // MARK: Object API
  subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> Self? { get }
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

  var rawString: String? { get }

  func withCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T?

  var string: String? { get }
}

public extension JSONValueProtocol {

  @inlinable
  subscript<T: StringProtocol>(key: T) -> Self? {
    key.utf8.withContiguousBuffer { buffer in
      buffer.withMemoryRebound(to: CChar.self) { keyBuffer in
        self[keyBuffer]
      }
    }
  }

  @inline(never)
  var description: String {
    if isString {
      return string!
    }
    if isUnsignedInteger {
      return uint64!.description
    }
    if isSignedInteger {
      return int64!.description
    }
    if isArray {
      return "Array"
    }
    if isObject {
      return "Object"
    }
    return "Unknown"
  }
}

public protocol MutableJSONValueProtocol: JSONValueProtocol {
  subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> Self? { get nonmutating set }
}

public extension MutableJSONValueProtocol {
  @inlinable
  subscript<T: StringProtocol>(key: T) -> Self? {
    get {
      key.utf8.withContiguousBuffer { buffer in
        buffer.withMemoryRebound(to: CChar.self) { keyBuffer in
          self[keyBuffer]
        }
      }
    }
    nonmutating set {
      key.utf8.withContiguousBuffer { buffer in
        buffer.withMemoryRebound(to: CChar.self) { keyBuffer in
          self[keyBuffer] = newValue
        }
      }
    }
  }
}
