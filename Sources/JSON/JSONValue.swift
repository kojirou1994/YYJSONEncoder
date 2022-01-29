import yyjson

public struct JSONValue {
  let val: UnsafeMutablePointer<yyjson_val>?
  let doc: JSON
}

public extension JSONValue {
  var exists: Bool {
    val != nil
  }

  var isNull: Bool {
    yyjson_is_null(val)
  }

  var isTrue: Bool {
    yyjson_is_true(val)
  }

  var isFalse: Bool {
    yyjson_is_false(val)
  }

  var isBool: Bool {
    yyjson_is_bool(val)
  }

  var isUnsignedInteger: Bool {
    yyjson_is_uint(val)
  }

  var isSignedInteger: Bool {
    yyjson_is_sint(val)
  }

  var isInteger: Bool {
    yyjson_is_int(val)
  }

  var isDouble: Bool {
    yyjson_is_real(val)
  }

  var isNumber: Bool {
    yyjson_is_num(val)
  }

  var isString: Bool {
    yyjson_is_str(val)
  }

  var isArray: Bool {
    yyjson_is_arr(val)
  }

  var isObject: Bool {
    yyjson_is_obj(val)
  }

  var isContainer: Bool {
    yyjson_is_ctn(val)
  }
}

public extension JSONValue {

  private func alertWrongType() {
    if val != nil {
      assertionFailure("Wrong Type! Real Type: \(String(cString: yyjson_get_type_desc(val)))")
    }
  }

  // MARK: Value API

  var bool: Bool? {
    guard isBool else {
      alertWrongType()
      return nil
    }
    return unsafe_yyjson_get_bool(val)
  }

  var uint: UInt64? {
    guard isUnsignedInteger else {
      alertWrongType()
      return nil
    }
    return unsafe_yyjson_get_uint(val)
  }

  var int: Int64? {
    guard isSignedInteger else {
      alertWrongType()
      return nil
    }
    return unsafe_yyjson_get_sint(val)
  }

  var double: Double? {
    guard isDouble else {
      alertWrongType()
      return nil
    }
    return unsafe_yyjson_get_real(val)
  }

  var string: String? {
    guard isString else {
      alertWrongType()
      return nil
    }
    return String(cString: unsafe_yyjson_get_str(val))
  }

  // MARK: Array API

  subscript(index: Int) -> Self {
    assert(isArray)
    return .init(val: yyjson_arr_get(val, index), doc: doc)
  }

  var array: JSONValueArray? {
    guard isArray else {
      alertWrongType()
      return nil
    }
    return .init(array: self)
  }

  // MARK: Object API

  subscript(key: String) -> Self {
    assert(isObject)
    return .init(val: yyjson_obj_get(val, key), doc: doc)
  }

  var object: JSONValueObject? {
    guard isObject else {
      alertWrongType()
      return nil
    }
    return .init(object: self)
  }

  // MARK: JSON Pointer

  func get(pointer: String) -> JSONValue {
    .init(val: yyjson_get_pointer(val, pointer), doc: doc)
  }
}

public struct JSONValueArray {
  let array: JSONValue
}

extension JSONValueArray: Collection {
  public func index(after i: Int) -> Int {
    i + 1
  }

  public var count: Int {
    yyjson_arr_size(array.val)
  }

  public var startIndex: Int {
    0
  }

  public var endIndex: Int {
    count
  }

  public subscript(position: Int) -> JSONValue {
    array[position]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_arr_iter = .init()
    yyjson_arr_iter_init(array.val, &iter)
    return .init(array: array, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let array: JSONValue
    var iter: yyjson_arr_iter

    public mutating func next() -> JSONValue? {
      if let val = yyjson_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

public struct JSONValueObject {
  let object: JSONValue
}

extension JSONValueObject: Sequence {

  public var count: Int {
    yyjson_obj_size(object.val)
  }

  public var underestimatedCount: Int { count }

  public subscript(key: String) -> JSONValue {
    object[key]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_obj_iter = .init()
    yyjson_obj_iter_init(object.val, &iter)
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

