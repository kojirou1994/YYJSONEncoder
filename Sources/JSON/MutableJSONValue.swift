import yyjson

public struct MutableJSONValue {
  let val: UnsafeMutablePointer<yyjson_mut_val>?
  let doc: MutableJSON
}

public extension MutableJSONValue {
  var exists: Bool {
    val != nil
  }

  var isNull: Bool {
    yyjson_mut_is_null(val)
  }

  var isTrue: Bool {
    yyjson_mut_is_true(val)
  }

  var isFalse: Bool {
    yyjson_mut_is_false(val)
  }

  var isBool: Bool {
    yyjson_mut_is_bool(val)
  }

  var isUnsignedInteger: Bool {
    yyjson_mut_is_uint(val)
  }

  var isSignedInteger: Bool {
    yyjson_mut_is_sint(val)
  }

  var isInteger: Bool {
    yyjson_mut_is_int(val)
  }

  var isDouble: Bool {
    yyjson_mut_is_real(val)
  }

  var isNumber: Bool {
    yyjson_mut_is_num(val)
  }

  var isString: Bool {
    yyjson_mut_is_str(val)
  }

  var isArray: Bool {
    yyjson_mut_is_arr(val)
  }

  var isObject: Bool {
    yyjson_mut_is_obj(val)
  }

  var isContainer: Bool {
    yyjson_mut_is_ctn(val)
  }
}

public extension MutableJSONValue {

  private func alertWrongType() {
    if val != nil {
      assertionFailure("Wrong Type! Real Type: \(String(cString: yyjson_mut_get_type_desc(val)))")
    }
  }

  // MARK: Value API

  var bool: Bool? {
    guard isBool else {
      alertWrongType()
      return nil
    }
    return yyjson_mut_get_bool(val)
  }

  var uint: UInt64? {
    guard isUnsignedInteger else {
      alertWrongType()
      return nil
    }
    return yyjson_mut_get_uint(val)
  }

  var int: Int64? {
    guard isSignedInteger else {
      alertWrongType()
      return nil
    }
    return yyjson_mut_get_sint(val)
  }

  var double: Double? {
    guard isDouble else {
      alertWrongType()
      return nil
    }
    return yyjson_mut_get_real(val)
  }

  var string: String? {
    guard isString else {
      alertWrongType()
      return nil
    }
    return String(cString: yyjson_mut_get_str(val))
  }

  // MARK: Array API

  subscript(index: Int) -> Self {
    assert(isArray)
    return .init(val: yyjson_mut_arr_get(val, index), doc: doc)
  }

  var array: MutableJSONValueArray? {
    guard isArray else {
      alertWrongType()
      return nil
    }
    return .init(array: self)
  }

  // MARK: Object API

  subscript(key: String) -> Self {
    assert(isObject)
    return .init(val: yyjson_mut_obj_get(val, key), doc: doc)
  }

  var object: MutableJSONValueObject? {
    guard isObject else {
      alertWrongType()
      return nil
    }
    return .init(object: self)
  }

  // MARK: MutableJSON Pointer

  func get(pointer: String) -> MutableJSONValue {
    .init(val: yyjson_mut_get_pointer(val, pointer), doc: doc)
  }
}

public struct MutableJSONValueArray {
  let array: MutableJSONValue
}

extension MutableJSONValueArray: Collection {
  public func index(after i: Int) -> Int {
    i + 1
  }

  public var count: Int {
    yyjson_mut_arr_size(array.val)
  }

  public var startIndex: Int {
    0
  }

  public var endIndex: Int {
    count
  }

  public subscript(position: Int) -> MutableJSONValue {
    array[position]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_arr_iter = .init()
    yyjson_mut_arr_iter_init(array.val, &iter)
    return .init(array: array, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let array: MutableJSONValue
    var iter: yyjson_mut_arr_iter

    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

public struct MutableJSONValueObject {
  let object: MutableJSONValue
}

extension MutableJSONValueObject: Sequence {

  public var count: Int {
    yyjson_mut_obj_size(object.val)
  }

  public var underestimatedCount: Int { count }

  public subscript(key: String) -> MutableJSONValue {
    object[key]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_obj_iter = .init()
    yyjson_mut_obj_iter_init(object.val, &iter)
    return .init(object: object, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let object: MutableJSONValue
    var iter: yyjson_mut_obj_iter

    public mutating func next() -> (key: MutableJSONValue, value: MutableJSONValue)? {
      if let keyPtr = yyjson_mut_obj_iter_next(&iter) {
        let key = MutableJSONValue(val: keyPtr, doc: object.doc)
        let value = MutableJSONValue(val: yyjson_mut_obj_iter_get_val(keyPtr), doc: object.doc)
        return (key, value)
      }
      return nil
    }

  }
}

