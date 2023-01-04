import yyjson
import CUtility

public struct JSONValue {

  @usableFromInline
  internal init(_ valPointer: UnsafeMutablePointer<yyjson_val>, _ document: JSON) {
    self.valPointer = valPointer
    self.document = document
  }

  @usableFromInline
  internal let valPointer: UnsafeMutablePointer<yyjson_val>

  @usableFromInline
  internal let document: JSON
}

extension JSONValue: JSONValueProtocol {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    yyjson_equals(lhs.valPointer, rhs.valPointer)
  }

  public struct Array: RawRepresentable {
    public init?(rawValue: JSONValue) {
      guard rawValue.isArray else {
        return nil
      }
      self.rawValue = rawValue
    }
    public let rawValue: JSONValue
  }

  public struct Object: RawRepresentable {
    public init?(rawValue: JSONValue) {
      guard rawValue.isObject else {
        return nil
      }
      self.rawValue = rawValue
    }
    public let rawValue: JSONValue
  }

  @inlinable
  public subscript(index: Int) -> JSONValue? {
    yyjson_arr_get(valPointer, index)
      .map { .init($0, document) }
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_get_type_desc(valPointer))
  }

  @inlinable
  public var isRaw: Bool {
    unsafe_yyjson_is_raw(valPointer)
  }

  @inlinable
  public var isNull: Bool {
    yyjson_is_null(valPointer)
  }

  @inlinable
  public var isTrue: Bool {
    yyjson_is_true(valPointer)
  }

  @inlinable
  public var isFalse: Bool {
    yyjson_is_false(valPointer)
  }

  @inlinable
  public var isBool: Bool {
    yyjson_is_bool(valPointer)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    yyjson_is_uint(valPointer)
  }

  @inlinable
  public var isSignedInteger: Bool {
    yyjson_is_sint(valPointer)
  }

  @inlinable
  public var isInteger: Bool {
    yyjson_is_int(valPointer)
  }

  @inlinable
  public var isDouble: Bool {
    yyjson_is_real(valPointer)
  }

  @inlinable
  public var isNumber: Bool {
    yyjson_is_num(valPointer)
  }

  @inlinable
  public var isString: Bool {
    yyjson_is_str(valPointer)
  }

  @inlinable
  public var isArray: Bool {
    yyjson_is_arr(valPointer)
  }

  @inlinable
  public var isObject: Bool {
    yyjson_is_obj(valPointer)
  }

  @inlinable
  public var isContainer: Bool {
    yyjson_is_ctn(valPointer)
  }

  @inlinable
  public func unsafeSetNull() {
    unsafe_yyjson_set_null(valPointer)
  }

  @inlinable
  public var unsafeBool: Bool {
    get {
      unsafe_yyjson_get_bool(valPointer)
    }
    nonmutating set {
      unsafe_yyjson_set_bool(valPointer, newValue)
    }
  }

  @inlinable
  public var unsafeUInt64: UInt64 {
    get {
      unsafe_yyjson_get_uint(valPointer)
    }
    nonmutating set {
      unsafe_yyjson_set_uint(valPointer, newValue)
    }
  }

  @inlinable
  public var unsafeInt64: Int64 {
    get {
      unsafe_yyjson_get_sint(valPointer)
    }
    nonmutating set {
      unsafe_yyjson_set_sint(valPointer, newValue)
    }
  }

  @inlinable
  public var unsafeDouble: Double {
    get {
      unsafe_yyjson_get_real(valPointer)
    }
    nonmutating set {
      unsafe_yyjson_set_real(valPointer, newValue)
    }
  }

  @inlinable
  public var unsafeRaw: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_raw(valPointer)
    }
  }

  @inlinable
  public var unsafeString: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_str(valPointer)
    }
  }

  @inlinable
  public var length: Int {
    unsafe_yyjson_get_len(valPointer)
  }

  @inlinable
  public func equals(toString buffer: UnsafeRawBufferPointer) -> Bool {
    unsafe_yyjson_equals_strn(valPointer, buffer.baseAddress, buffer.count)
  }

}

extension JSONValue.Array: JSONArrayProtocol {

  @inlinable
  public func value(at idx: Int) -> JSONValue? {
    yyjson_arr_get(rawValue.valPointer, idx)
      .map { JSONValue($0, rawValue.document) }
  }

  @inlinable
  public subscript(position: Int) -> JSONValue {
    assert(indices.contains(position))
    return value(at: position).unsafelyUnwrapped
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator: JSONContainerIterator {
    @usableFromInline
    internal init(_ array: JSONValue) {
      assert(array.isArray)
      self.array = array
      self.iter = .init()
    }

    @usableFromInline
    internal let array: JSONValue

    @usableFromInline
    internal var iter: yyjson_arr_iter

    @inlinable
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_arr_iter_has_next)
    }

    @inlinable
    public mutating func reset() {
      yyjson_arr_iter_init(array.valPointer, &iter)
    }

    @inlinable
    public mutating func next() -> JSONValue? {
      if let val = yyjson_arr_iter_next(&iter) {
        return .init(val, array.document)
      }
      return nil
    }

  }

  @inlinable
  public var first: JSONValue? {
    yyjson_arr_get_first(rawValue.valPointer)
      .map { JSONValue($0, rawValue.document) }
  }

  @inlinable
  public var last: JSONValue? {
    yyjson_arr_get_last(rawValue.valPointer)
      .map { JSONValue($0, rawValue.document) }
  }
}

extension JSONValue.Object: JSONObjectProtocol {
  @inlinable
  public func value(for keyBuffer: UnsafeRawBufferPointer) -> Value? {
    yyjson_obj_getn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
      .map { JSONValue($0, rawValue.document) }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator: JSONObjectIterator {

    @usableFromInline
    internal init(_ object: JSONValue) {
      assert(object.isObject)
      self.object = object
      self.iter = .init()
    }

    @usableFromInline
    internal let object: JSONValue

    @usableFromInline
    internal var iter: yyjson_obj_iter

    @inlinable
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_obj_iter_has_next)
    }

    @inlinable
    public func value(for key: JSONValue) -> JSONValue {
      .init(yyjson_obj_iter_get_val(key.valPointer), object.document)
    }

    @inlinable
    public mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> JSONValue? {
      yyjson_obj_iter_getn(&iter, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init($0, object.document) }
    }

    @inlinable
    public mutating func reset() {
      yyjson_obj_iter_init(object.valPointer, &iter)
    }

    @inlinable
    public mutating func next() -> JSONValue? {
      yyjson_obj_iter_next(&iter)
        .map { JSONValue($0, object.document) }
    }

  }
}

