import yyjson

public struct RawJSONValue {

  @usableFromInline
  let rawPtr: UnsafeMutableRawPointer

  @usableFromInline
  var valPtr: UnsafeMutablePointer<yyjson_val> {
    rawPtr.assumingMemoryBound(to: yyjson_val.self)
  }
}

public protocol JSONValueProtocol {
  var rawJSONValue: RawJSONValue { get }

  // MARK: JSON Pointer
  func value(withPointer pointer: String) -> Self
}

public extension JSONValueProtocol {

  @inlinable
  var typeDescriptionCString: UnsafePointer<CChar> {
    yyjson_get_type_desc(rawJSONValue.valPtr)
  }

  @inlinable
  var typeDescription: String {
    .init(cString: typeDescriptionCString)
  }

  @inlinable
  var isNull: Bool {
    unsafe_yyjson_is_null(rawJSONValue.rawPtr)
  }

  @inlinable
  var isTrue: Bool {
    unsafe_yyjson_is_true(rawJSONValue.rawPtr)
  }

  @inlinable
  var isFalse: Bool {
    unsafe_yyjson_is_false(rawJSONValue.rawPtr)
  }

  @inlinable
  var isBool: Bool {
    unsafe_yyjson_is_bool(rawJSONValue.rawPtr)
  }

  @inlinable
  var isUnsignedInteger: Bool {
    unsafe_yyjson_is_uint(rawJSONValue.rawPtr)
  }

  @inlinable
  var isSignedInteger: Bool {
    unsafe_yyjson_is_sint(rawJSONValue.rawPtr)
  }

  @inlinable
  var isInteger: Bool {
    unsafe_yyjson_is_int(rawJSONValue.rawPtr)
  }

  @inlinable
  var isDouble: Bool {
    unsafe_yyjson_is_real(rawJSONValue.rawPtr)
  }

  @inlinable
  var isNumber: Bool {
    unsafe_yyjson_is_num(rawJSONValue.rawPtr)
  }

  @inlinable
  var isString: Bool {
    unsafe_yyjson_is_str(rawJSONValue.rawPtr)
  }

  @inlinable
  var isArray: Bool {
    unsafe_yyjson_is_arr(rawJSONValue.rawPtr)
  }

  @inlinable
  var isObject: Bool {
    unsafe_yyjson_is_obj(rawJSONValue.rawPtr)
  }

  @inlinable
  var isContainer: Bool {
    unsafe_yyjson_is_ctn(rawJSONValue.rawPtr)
  }

  // MARK: Value API

  @inlinable
  var bool: Bool? {
    guard isBool else {
      return nil
    }
    return unsafe_yyjson_get_bool(rawJSONValue.rawPtr)
  }

  @inlinable
  var uint: UInt64? {
    guard isUnsignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_uint(rawJSONValue.rawPtr)
  }

  @inlinable
  var int: Int64? {
    guard isSignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_sint(rawJSONValue.rawPtr)
  }

  @inlinable
  var double: Double? {
    guard isDouble else {
      return nil
    }
    return unsafe_yyjson_get_real(rawJSONValue.rawPtr)
  }

  @inlinable
  var cString: UnsafePointer<CChar>? {
    guard isString else {
      return nil
    }
    return unsafe_yyjson_get_str(rawJSONValue.rawPtr)
  }

  @inlinable
  var string: String? {
    cString.map(String.init)
  }
}

public struct JSONValue: JSONValueProtocol {
  public func value(withPointer pointer: String) -> JSONValue {
    .init(val: yyjson_get_pointer(rawJSONValue.valPtr, pointer), doc: doc)
  }

  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_val>, doc: JSON) {
    self.rawJSONValue = .init(rawPtr: val)
    self.doc = doc
  }

  public let rawJSONValue: RawJSONValue

  @usableFromInline
  let doc: JSON
}

public extension JSONValue {

  // MARK: Array API

  @inlinable
  subscript(index: Int) -> Self? {
    yyjson_arr_get(rawJSONValue.valPtr, index).map { .init(val: $0, doc: doc) }
  }

  @inlinable
  var array: JSONValueArray? {
    guard isArray else {
      return nil
    }
    return .init(value: self)
  }

  // MARK: Object API

  @inlinable
  subscript(key: String) -> Self? {
    yyjson_obj_get(rawJSONValue.valPtr, key).map { .init(val: $0, doc: doc) }
  }

  @inlinable
  var object: JSONValueObject? {
    guard isObject else {
      return nil
    }
    return .init(object: self)
  }

}

public struct JSONValueArray {
  @usableFromInline
  internal init(value: JSONValue) {
    self.value = value
  }

  @usableFromInline
  let value: JSONValue
}

extension JSONValueArray: Collection {
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
    public mutating func next() -> JSONValue? {
      if let val = yyjson_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

public struct JSONValueObject {
  @usableFromInline
  internal init(object: JSONValue) {
    self.object = object
  }

  let object: JSONValue
}

extension JSONValueObject: Sequence {

  public var count: Int {
    unsafe_yyjson_get_len(object.rawJSONValue.rawPtr)
  }

  public var underestimatedCount: Int { count }

  public subscript(key: String) -> JSONValue? {
    object[key]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_obj_iter = .init()
    yyjson_obj_iter_init(object.rawJSONValue.valPtr, &iter)
    return .init(object: object, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let object: JSONValue
    var iter: yyjson_obj_iter

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

