import yyjson
import CUtility

public struct JSONValue {

  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_val>, doc: JSON) {
    self.val = val
    self.doc = doc
  }

  @usableFromInline
  internal let val: UnsafeMutablePointer<yyjson_val>

  @usableFromInline
  internal let doc: JSON
}

extension JSONValue: JSONValueProtocol {

  @inlinable
  public static func == (lhs: JSONValue, rhs: JSONValue) -> Bool {
    yyjson_equals(lhs.val, rhs.val)
  }

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

  @inlinable
  public func value(withPointer pointer: String) -> JSONValue {
    .init(val: yyjson_get_pointer(val, pointer), doc: doc)
  }

  @inlinable
  public subscript(index: Int) -> JSONValue? {
    yyjson_arr_get(val, index).map { .init(val: $0, doc: doc) }
  }

  @inlinable
  public var array: Array? {
    guard isArray else {
      return nil
    }
    return .init(value: self)
  }

  @inlinable
  public var object: Object? {
    guard isObject else {
      return nil
    }
    return .init(value: self)
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_get_type_desc(val))
  }

  @inlinable
  public var isRaw: Bool {
    yyjson_is_raw(val)
  }

  @inlinable
  public var isNull: Bool {
    yyjson_is_null(val)
  }

  @inlinable
  public var isTrue: Bool {
    yyjson_is_true(val)
  }

  @inlinable
  public var isFalse: Bool {
    yyjson_is_false(val)
  }

  @inlinable
  public var isBool: Bool {
    yyjson_is_bool(val)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    yyjson_is_uint(val)
  }

  @inlinable
  public var isSignedInteger: Bool {
    yyjson_is_sint(val)
  }

  @inlinable
  public var isInteger: Bool {
    yyjson_is_int(val)
  }

  @inlinable
  public var isDouble: Bool {
    yyjson_is_real(val)
  }

  @inlinable
  public var isNumber: Bool {
    yyjson_is_num(val)
  }

  @inlinable
  public var isString: Bool {
    yyjson_is_str(val)
  }

  @inlinable
  public var isArray: Bool {
    yyjson_is_arr(val)
  }

  @inlinable
  public var isObject: Bool {
    yyjson_is_obj(val)
  }

  @inlinable
  public var isContainer: Bool {
    yyjson_is_ctn(val)
  }

  @inlinable
  public var unsafeBool: Bool {
    unsafe_yyjson_get_bool(val)
  }

  @inlinable
  public var unsafeUInt64: UInt64 {
    unsafe_yyjson_get_uint(val)
  }

  @inlinable
  public var unsafeInt64: Int64 {
    unsafe_yyjson_get_sint(val)
  }

  @inlinable
  public var unsafeDouble: Double {
    unsafe_yyjson_get_real(val)
  }

  @inlinable
  public var unsafeRaw: UnsafePointer<CChar> {
    unsafe_yyjson_get_raw(val)
  }

  @inlinable
  public var unsafeString: UnsafePointer<CChar> {
    unsafe_yyjson_get_str(val)
  }

  @inlinable
  public func withRawCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    guard let raw = yyjson_get_raw(val) else {
      return nil
    }
    return try body(raw)
  }

  @inlinable
  public func withCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    guard let string = yyjson_get_str(val) else {
      return nil
    }
    return try body(string)
  }

  public func equals(toString buffer: UnsafeRawBufferPointer) -> Bool {
    yyjson_equals_strn(val, buffer.baseAddress, buffer.count)
  }

}

extension JSONValue.Array: Collection, RandomAccessCollection {

  @inlinable
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  public var count: Int {
    yyjson_get_len(value.val)
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
  public var first: Element? {
    yyjson_arr_get_first(value.val).map { JSONValue(val: $0, doc: value.doc) }
  }

  @inlinable
  public var last: Element? {
    yyjson_arr_get_last(value.val).map { JSONValue(val: $0, doc: value.doc) }
  }

  @inlinable
  public subscript(position: Int) -> JSONValue {
    precondition(0..<count ~= position)
    return .init(val: yyjson_arr_get(value.val, position), doc: value.doc)
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_arr_iter = .init()
    yyjson_arr_iter_init(value.val, &iter)
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

extension JSONValue.Object: Sequence, JSONObjectProtocol {

  @inlinable
  public var count: Int {
    yyjson_get_len(value.val)
  }

  @inlinable
  public var underestimatedCount: Int { count }

  @inlinable
  public subscript(keyBuffer: UnsafeRawBufferPointer) -> JSONValue? {
    yyjson_obj_getn(value.val, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init(val: $0, doc: value.doc) }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_obj_iter = .init()
    yyjson_obj_iter_init(value.val, &iter)
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

