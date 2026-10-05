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

  @export(implementation)
  public var exists: Bool {
    rawAddress != nil
  }

  @export(implementation)
  public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
    yyjson_equals(lhs.rawAddress, rhs.rawAddress)
  }

  @export(implementation)
  public var typeDescription: StaticCString {
    .init(cString: yyjson_get_type_desc(rawAddress))
  }

  @export(implementation)
  public var isRaw: Bool {
    yyjson_is_raw(rawAddress)
  }

  @export(implementation)
  public var isNull: Bool {
    yyjson_is_null(rawAddress)
  }

  @export(implementation)
  public var isTrue: Bool {
    yyjson_is_true(rawAddress)
  }

  @export(implementation)
  public var isFalse: Bool {
    yyjson_is_false(rawAddress)
  }

  @export(implementation)
  public var isBool: Bool {
    yyjson_is_bool(rawAddress)
  }

  @export(implementation)
  public var isUnsignedInteger: Bool {
    yyjson_is_uint(rawAddress)
  }

  @export(implementation)
  public var isSignedInteger: Bool {
    yyjson_is_sint(rawAddress)
  }

  @export(implementation)
  public var isInteger: Bool {
    yyjson_is_int(rawAddress)
  }

  @export(implementation)
  public var isDouble: Bool {
    yyjson_is_real(rawAddress)
  }

  @export(implementation)
  public var isNumber: Bool {
    yyjson_is_num(rawAddress)
  }

  @export(implementation)
  public var isString: Bool {
    yyjson_is_str(rawAddress)
  }

  @export(implementation)
  public var isArray: Bool {
    yyjson_is_arr(rawAddress)
  }

  @export(implementation)
  public var isObject: Bool {
    yyjson_is_obj(rawAddress)
  }

  @export(implementation)
  public var isContainer: Bool {
    yyjson_is_ctn(rawAddress)
  }

  @export(implementation)
  public func unsafeSetNull() {
    unsafe_yyjson_set_null(rawAddress)
  }

  @export(implementation)
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

  @export(implementation)
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

  @export(implementation)
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

  @export(implementation)
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

  @export(implementation)
  public var unsafeNumber: Double {
    get {
      assert(isNumber)
      return unsafe_yyjson_get_num(rawAddress)
    }
  }

//  @export(implementation)
//  public var unsafeRaw: ReferenceCString {
//    @_lifetime(borrow self)
//    get {
//      assert(isRaw)
//      return _overrideLifetime(.init(cString: unsafe_yyjson_get_raw(rawAddress)), borrowing: self)
//    }
//  }
//
//  @export(implementation)
//  public var unsafeString: ReferenceCString {
//    @_lifetime(borrow self)
//    get {
//      assert(isString)
//      return _overrideLifetime(.init(cString: unsafe_yyjson_get_str(rawAddress)), borrowing: self)
//    }
//  }

  @export(implementation)
  public var unsafeRaw: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_raw(rawAddress)
    }
  }

  @export(implementation)
  public var unsafeString: UnsafePointer<CChar> {
    get {
      unsafe_yyjson_get_str(rawAddress)
    }
  }

  @export(implementation)
  public var length: Int {
    yyjson_get_len(rawAddress)
  }

  @export(implementation)
  public func equals(to string: UnsafeRawBufferPointer) -> Bool {
    yyjson_equals_strn(rawAddress, string.baseAddress, string.count)
  }

  @export(implementation)
  public func set(fpToFloat: Bool) {
    yyjson_set_fp_to_float(rawAddress, fpToFloat)
  }

  @export(implementation)
  public func set(prec: CInt) {
    yyjson_set_fp_to_fixed(rawAddress, prec)
  }

  @export(implementation)
  public func set(noesc: Bool) {
    yyjson_set_str_noesc(rawAddress, noesc)
  }

  @export(implementation)
  public func writeNumber(to string: UnsafeMutablePointer<CChar>) {
    yyjson_write_number(rawAddress, string)
  }

  @export(implementation)
  @_lifetime(copy self)
  public subscript(index: Int) -> Self {
    _overrideLifetime(.init(yyjson_arr_get(rawAddress, index)), copying: self)
  }

  @export(implementation)
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

//    @export(implementation)
//    public var hasNext: Bool {
//      @_lifetime(&self)
//      @_lifetime(self: copy self)
//      mutating get {
//        yyjson_arr_iter_has_next(&iter)
//      }
//    }

//    @export(implementation)
//    @_lifetime(&self)
//    @_lifetime(self: copy self)
//    public mutating func reset() {
//      yyjson_arr_iter_init(rawAddress.rawAddress, &iter)
//    }

//    @export(implementation)
//    @_lifetime(copy self)
//    public mutating func next() -> JSONValue {
//      _overrideLifetime(.init(yyjson_arr_iter_next(&iter)), copying: self)
//    }

  }

//  @export(implementation)
//  public var first: JSONValue {
//    yyjson_arr_get_first(rawValue.valPointer)
//  }
//
//  @export(implementation)
//  public var last: JSONValue {
//    yyjson_arr_get_last(rawValue.valPointer)
//  }
}
/*
extension JSONValue.Object: JSONObjectProtocol {
  @export(implementation)
  public func value(for keyBuffer: UnsafeRawBufferPointer) -> Value? {
    yyjson_obj_getn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
      .map { JSONValue($0, rawValue.document) }
  }
 @export(implementation)
 subscript(key: some ContiguousUTF8Bytes) -> Value? {
   key.withContiguousUTF8Bytes(value(for:))
 }

  @export(implementation)
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

    @export(implementation)
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_obj_iter_has_next)
    }

    @export(implementation)
    public func value(for key: JSONValue) -> JSONValue {
      .init(yyjson_obj_iter_get_val(key.valPointer), object.document)
    }

    @export(implementation)
    public mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> JSONValue? {
      yyjson_obj_iter_getn(&iter, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init($0, object.document) }
    }

    @export(implementation)
    public mutating func reset() {
      yyjson_obj_iter_init(object.valPointer, &iter)
    }

    @export(implementation)
    public mutating func next() -> JSONValue? {
      yyjson_obj_iter_next(&iter)
        .map { JSONValue($0, object.document) }
    }

  }
}

*/
