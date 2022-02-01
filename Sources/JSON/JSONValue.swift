import yyjson

public struct RawJSONValue {

  @usableFromInline
  let val: UnsafeMutableRawPointer?
}

public protocol JSONValueProtocol {
  var rawJSONValue: RawJSONValue { get }
}

public extension JSONValueProtocol {

  private var ptr: UnsafeMutablePointer<yyjson_val>? {
    rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self)
  }

  var typeDescriptionCString: UnsafePointer<CChar> {
    yyjson_get_type_desc(ptr)
  }

  var typeDescription: String {
    .init(cString: typeDescriptionCString)
  }

  var exists: Bool {
    rawJSONValue.val != nil
  }

  var isNull: Bool {
    yyjson_is_null(ptr)
  }

  var isTrue: Bool {
    yyjson_is_true(ptr)
  }

  var isFalse: Bool {
    yyjson_is_false(ptr)
  }

  var isBool: Bool {
    yyjson_is_bool(ptr)
  }

  var isUnsignedInteger: Bool {
    yyjson_is_uint(ptr)
  }

  var isSignedInteger: Bool {
    yyjson_is_sint(ptr)
  }

  var isInteger: Bool {
    yyjson_is_int(ptr)
  }

  var isDouble: Bool {
    yyjson_is_real(ptr)
  }

  var isNumber: Bool {
    yyjson_is_num(ptr)
  }

  var isString: Bool {
    yyjson_is_str(ptr)
  }

  var isArray: Bool {
    yyjson_is_arr(ptr)
  }

  var isObject: Bool {
    yyjson_is_obj(ptr)
  }

  var isContainer: Bool {
    yyjson_is_ctn(ptr)
  }

  // MARK: Value API

  var bool: Bool? {
    guard isBool else {
      return nil
    }
    return unsafe_yyjson_get_bool(rawJSONValue.val)
  }

  var uint: UInt64? {
    guard isUnsignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_uint(rawJSONValue.val)
  }

  var int: Int64? {
    guard isSignedInteger else {
      return nil
    }
    return unsafe_yyjson_get_sint(rawJSONValue.val)
  }

  var double: Double? {
    guard isDouble else {
      return nil
    }
    return unsafe_yyjson_get_real(rawJSONValue.val)
  }

  var cString: UnsafePointer<CChar>? {
    guard isString else {
      return nil
    }
    return unsafe_yyjson_get_str(rawJSONValue.val)
  }

  var string: String? {
    cString.map(String.init)
  }
}

public struct JSONValue: JSONValueProtocol {
  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_val>, doc: JSON) {
    self.rawJSONValue = .init(val: val)
    self.doc = doc
  }

  public let rawJSONValue: RawJSONValue

  @usableFromInline
  let doc: JSON
}

public extension JSONValue {

  // MARK: Array API

  @inlinable
  subscript(index: Int) -> Self {
    assert(isArray)
    return .init(val: yyjson_arr_get(rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self), index), doc: doc)
  }

  @inlinable
  var array: JSONValueArray? {
    guard isArray else {
      return nil
    }
    return .init(array: self)
  }

  // MARK: Object API

  @inlinable
  subscript(key: String) -> Self {
    assert(isObject)
    return .init(val: yyjson_obj_get(rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self), key), doc: doc)
  }

  @inlinable
  var object: JSONValueObject? {
    guard isObject else {
      return nil
    }
    return .init(object: self)
  }

  // MARK: JSON Pointer

  func get(pointer: String) -> JSONValue {
    .init(val: yyjson_get_pointer(rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self), pointer), doc: doc)
  }
}

public struct JSONValueArray {
  @usableFromInline
  internal init(array: JSONValue) {
    self.array = array
  }

  @usableFromInline
  let array: JSONValue
}

extension JSONValueArray: Collection {
  @inlinable
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  public var count: Int {
    yyjson_arr_size(array.rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self))
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
    array[position]
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_arr_iter = .init()
    yyjson_arr_iter_init(array.rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self), &iter)
    return .init(array: array, iter: iter)
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
    yyjson_obj_size(object.rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self))
  }

  public var underestimatedCount: Int { count }

  public subscript(key: String) -> JSONValue {
    object[key]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_obj_iter = .init()
    yyjson_obj_iter_init(object.rawJSONValue.val?.assumingMemoryBound(to: yyjson_val.self), &iter)
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

