import yyjson

public struct RawJSONValue {

  @usableFromInline
  let rawPtr: UnsafeMutableRawPointer

  @usableFromInline
  var valPtr: UnsafeMutablePointer<yyjson_val> {
    rawPtr.assumingMemoryBound(to: yyjson_val.self)
  }
}

public protocol JSONValueProtocol: CustomStringConvertible {
  associatedtype Array where Array: Collection, Array.Element == Self
  associatedtype Object where Object: Sequence, Object.Element == (key: Self, value: Self)

  var rawJSONValue: RawJSONValue { get }

  // MARK: JSON Pointer
  func value(withPointer pointer: String) -> Self

  // MARK: Array API
  subscript(index: Int) -> Self? { get }
  var array: Array? { get }

  // MARK: Object API
  subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> Self? { get }
  var object: Object? { get }
}

public extension JSONValueProtocol {

  @_alwaysEmitIntoClient
  var typeDescriptionCString: UnsafePointer<CChar> {
    yyjson_get_type_desc(rawJSONValue.valPtr)
  }

  @_alwaysEmitIntoClient
  var typeDescription: String {
    .init(cString: typeDescriptionCString)
  }

  @_alwaysEmitIntoClient
  var isNull: Bool {
    unsafe_yyjson_is_null(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isTrue: Bool {
    unsafe_yyjson_is_true(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isFalse: Bool {
    unsafe_yyjson_is_false(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isBool: Bool {
    unsafe_yyjson_is_bool(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isUnsignedInteger: Bool {
    unsafe_yyjson_is_uint(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isSignedInteger: Bool {
    unsafe_yyjson_is_sint(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isInteger: Bool {
    unsafe_yyjson_is_int(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isDouble: Bool {
    unsafe_yyjson_is_real(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isNumber: Bool {
    unsafe_yyjson_is_num(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isString: Bool {
    unsafe_yyjson_is_str(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isArray: Bool {
    unsafe_yyjson_is_arr(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isObject: Bool {
    unsafe_yyjson_is_obj(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var isContainer: Bool {
    unsafe_yyjson_is_ctn(rawJSONValue.rawPtr)
  }

  // MARK: Value API

  @_alwaysEmitIntoClient
  var bool: Bool? {
    guard isBool else {
      return nil
    }
    return unsafe_yyjson_get_bool(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var uint: UInt64? {
    guard isUnsignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_uint(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var int: Int64? {
    guard isSignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_sint(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var double: Double? {
    guard isDouble else {
      return nil
    }
    return unsafe_yyjson_get_real(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var cString: UnsafePointer<CChar>? {
    guard isString else {
      return nil
    }
    return unsafe_yyjson_get_str(rawJSONValue.rawPtr)
  }

  @_alwaysEmitIntoClient
  var string: String? {
    cString.map(String.init)
  }

  @_alwaysEmitIntoClient
  subscript<T: StringProtocol>(key: T) -> Self? {
    key.utf8.withContiguousBuffer { buffer in
      self[.init(start: .init(OpaquePointer(buffer.baseAddress)), count: buffer.count)]
    }
  }
}

public extension JSONValueProtocol {
  @inline(never)
  var description: String {
    if isString {
      return string!
    }
    if isUnsignedInteger {
      return uint!.description
    }
    if isSignedInteger {
      return int!.description
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

public struct JSONValue {

  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_val>, doc: JSON) {
    self.rawJSONValue = .init(rawPtr: val)
    self.doc = doc
  }

  public let rawJSONValue: RawJSONValue

  @usableFromInline
  let doc: JSON
}

extension JSONValue: JSONValueProtocol {

  public struct Array {
    @usableFromInline
    internal init(value: JSONValue) {
      assert(value.isArray)
      self.value = value
    }

    @usableFromInline
    let value: JSONValue
  }

  public struct Object {
    @usableFromInline
    internal init(value: JSONValue) {
      assert(value.isObject)
      self.value = value
    }

    @usableFromInline
    let value: JSONValue
  }

  @_alwaysEmitIntoClient
  public func value(withPointer pointer: String) -> JSONValue {
    .init(val: yyjson_get_pointer(rawJSONValue.valPtr, pointer), doc: doc)
  }

  @_alwaysEmitIntoClient
  public subscript(index: Int) -> JSONValue? {
    yyjson_arr_get(rawJSONValue.valPtr, index).map { .init(val: $0, doc: doc) }
  }

  @_alwaysEmitIntoClient
  public var array: Array? {
    guard isArray else {
      return nil
    }
    return .init(value: self)
  }

  @_alwaysEmitIntoClient
  public subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> JSONValue? {
    yyjson_obj_getn(rawJSONValue.valPtr, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init(val: $0, doc: doc) }
  }

  @_alwaysEmitIntoClient
  public var object: Object? {
    guard isObject else {
      return nil
    }
    return .init(value: self)
  }

}

extension JSONValue.Array: Collection {
  @inlinable
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  public var count: Int {
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
  }

  @inlinable
  public var startIndex: Int {
    0
  }

  @inlinable
  public var endIndex: Int {
    count
  }

  @inlinable
  public subscript(position: Int) -> JSONValue {
    precondition(0..<count ~= position)
    return .init(val: yyjson_arr_get(value.rawJSONValue.valPtr, position), doc: value.doc)
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_arr_iter = .init()
    yyjson_arr_iter_init(value.rawJSONValue.valPtr, &iter)
    return .init(array: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal init(array: JSONValue, iter: yyjson_arr_iter) {
      self.array = array
      self.iter = iter
    }

    @usableFromInline
    let array: JSONValue

    @usableFromInline
    var iter: yyjson_arr_iter

    @inlinable
    public var hasNext: Bool {
      iter.idx < iter.max
    }

    @inlinable
    public mutating func next() -> JSONValue? {
      if let val = yyjson_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

extension JSONValue.Object: Sequence {

  @inlinable
  public var count: Int {
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
  }

  @inlinable
  public var underestimatedCount: Int { count }

  @inlinable
  public subscript(key: String) -> JSONValue? {
    value[key]
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_obj_iter = .init()
    yyjson_obj_iter_init(value.rawJSONValue.valPtr, &iter)
    return .init(object: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal init(object: JSONValue, iter: yyjson_obj_iter) {
      self.object = object
      self.iter = iter
    }

    @usableFromInline
    let object: JSONValue

    @usableFromInline
    var iter: yyjson_obj_iter

    @inlinable
    public mutating func next() -> (key: JSONValue, value: JSONValue)? {
      if let keyPtr = yyjson_obj_iter_next(&iter) {
        let key = JSONValue(val: keyPtr, doc: object.doc)
        let value = JSONValue(val: yyjson_obj_iter_get_val(keyPtr), doc: object.doc)
        return (key, value)
      }
      return nil
    }

  }
}

