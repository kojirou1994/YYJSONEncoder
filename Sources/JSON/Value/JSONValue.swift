import yyjson
import CUtility

public struct JSONValue: ~Copyable, ~Escapable {

  @usableFromInline
  @_lifetime(borrow rawAddress)
  internal init(_ rawAddress: UnsafeMutablePointer<yyjson_val>?) {
    self.rawAddress = rawAddress
  }

  @usableFromInline
  internal let rawAddress: UnsafeMutablePointer<yyjson_val>?
}

extension JSONValue: JSONValueProtocol {

  @inlinable
  public var exists: Bool {
    rawAddress != nil
  }

  @inlinable
  public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
    yyjson_equals(lhs.rawAddress, rhs.rawAddress)
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_get_type_desc(rawAddress))
  }

  @inlinable
  public var isRaw: Bool {
    yyjson_is_raw(rawAddress)
  }

  @inlinable
  public var isNull: Bool {
    yyjson_is_null(rawAddress)
  }

  @inlinable
  public var isTrue: Bool {
    yyjson_is_true(rawAddress)
  }

  @inlinable
  public var isFalse: Bool {
    yyjson_is_false(rawAddress)
  }

  @inlinable
  public var isBool: Bool {
    yyjson_is_bool(rawAddress)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    yyjson_is_uint(rawAddress)
  }

  @inlinable
  public var isSignedInteger: Bool {
    yyjson_is_sint(rawAddress)
  }

  @inlinable
  public var isInteger: Bool {
    yyjson_is_int(rawAddress)
  }

  @inlinable
  public var isDouble: Bool {
    yyjson_is_real(rawAddress)
  }

  @inlinable
  public var isNumber: Bool {
    yyjson_is_num(rawAddress)
  }

  @inlinable
  public var isString: Bool {
    yyjson_is_str(rawAddress)
  }

  @inlinable
  public var isArray: Bool {
    yyjson_is_arr(rawAddress)
  }

  @inlinable
  public var isObject: Bool {
    yyjson_is_obj(rawAddress)
  }

  @inlinable
  public var isContainer: Bool {
    yyjson_is_ctn(rawAddress)
  }

  @inlinable
  public func unsafeSetNull() {
    unsafe_yyjson_set_null(rawAddress)
  }

  @inlinable
  public var unsafeBool: Bool {
    get {
      assert(isBool)
      return unsafe_yyjson_get_bool(rawAddress)
    }
    nonmutating set {
      assert(isBool)
      unsafe_yyjson_set_bool(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeUInt64: UInt64 {
    get {
      assert(isUnsignedInteger)
      return unsafe_yyjson_get_uint(rawAddress)
    }
    nonmutating set {
      assert(isUnsignedInteger)
      unsafe_yyjson_set_uint(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeInt64: Int64 {
    get {
      assert(isSignedInteger)
      return unsafe_yyjson_get_sint(rawAddress)
    }
    nonmutating set {
      assert(isSignedInteger)
      unsafe_yyjson_set_sint(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeDouble: Double {
    get {
      assert(isDouble)
      return unsafe_yyjson_get_real(rawAddress)
    }
    nonmutating set {
      assert(isDouble)
      unsafe_yyjson_set_real(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeNumber: Double {
    get {
      assert(isNumber)
      return unsafe_yyjson_get_num(rawAddress)
    }
  }

//  @inlinable
//  public var unsafeRaw: ReferenceCString {
//    @_lifetime(borrow self)
//    get {
//      assert(isRaw)
//      return _overrideLifetime(.init(cString: unsafe_yyjson_get_raw(rawAddress)), borrowing: self)
//    }
//  }
//
//  @inlinable
//  public var unsafeString: ReferenceCString {
//    @_lifetime(borrow self)
//    get {
//      assert(isString)
//      return _overrideLifetime(.init(cString: unsafe_yyjson_get_str(rawAddress)), borrowing: self)
//    }
//  }

  @inlinable
  public var unsafeRaw: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_raw(rawAddress)
    }
  }

  @inlinable
  public var unsafeString: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_str(rawAddress)
    }
  }

  @inlinable
  public var length: Int {
    yyjson_get_len(rawAddress)
  }

  @inlinable
  public func equals(to string: UnsafeRawBufferPointer) -> Bool {
    yyjson_equals_strn(rawAddress, string.baseAddress, string.count)
  }

  @inlinable
  public func set(fpToFloat: Bool) {
    yyjson_set_fp_to_float(rawAddress, fpToFloat)
  }

  @inlinable
  public func set(prec: CInt) {
    yyjson_set_fp_to_fixed(rawAddress, prec)
  }

  @inlinable
  public func set(noesc: Bool) {
    yyjson_set_str_noesc(rawAddress, noesc)
  }

  @inlinable
  public func writeNumber(to string: UnsafeMutablePointer<CChar>) {
    yyjson_write_number(rawAddress, string)
  }

  @inlinable
  @_lifetime(copy self)
  public subscript(index: Int) -> Self {
    _overrideLifetime(.init(yyjson_arr_get(rawAddress, index)), copying: self)
  }

  @inlinable
  @inline(always)
  @_lifetime(copy self)
  public subscript(key: some ContiguousUTF8Bytes) -> Self {
    _overrideLifetime(.init(key.withContiguousUTF8Bytes { keyBuffer in
      yyjson_obj_getn(rawAddress, keyBuffer.baseAddress, keyBuffer.count)
    }), copying: self)
  }
}

extension JSONValue {

  public struct ArrayIterator: ~Copyable, ~Escapable {
//    @usableFromInline
//    @_lifetime(copy array)
//    internal init(_ array: borrowing JSONValue) {
//      assert(array.isArray)
//      self.rawAddress = array
//      self.iter = .init()
//    }
//
//    @usableFromInline
//    internal let rawAddress: JSONValue
//
//    @usableFromInline
//    internal var iter: yyjson_arr_iter

//    @inlinable
//    public var hasNext: Bool {
//      @_lifetime(&self)
//      @_lifetime(self: copy self)
//      mutating get {
//        yyjson_arr_iter_has_next(&iter)
//      }
//    }

//    @inlinable
//    @_lifetime(&self)
//    @_lifetime(self: copy self)
//    public mutating func reset() {
//      yyjson_arr_iter_init(rawAddress.rawAddress, &iter)
//    }

//    @inlinable
//    @_lifetime(copy self)
//    public mutating func next() -> JSONValue {
//      _overrideLifetime(.init(yyjson_arr_iter_next(&iter)), copying: self)
//    }

  }

//  @inlinable
//  public var first: JSONValue {
//    yyjson_arr_get_first(rawValue.valPointer)
//  }
//
//  @inlinable
//  public var last: JSONValue {
//    yyjson_arr_get_last(rawValue.valPointer)
//  }
}
/*
extension JSONValue.Object: JSONObjectProtocol {
  @inlinable
  public func value(for keyBuffer: UnsafeRawBufferPointer) -> Value? {
    yyjson_obj_getn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
      .map { JSONValue($0, rawValue.document) }
  }
 @inlinable
 subscript(key: some ContiguousUTF8Bytes) -> Value? {
   key.withContiguousUTF8Bytes(value(for:))
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

*/
