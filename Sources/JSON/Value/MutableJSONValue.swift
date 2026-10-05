import yyjson
import CUtility

public struct MutableJSONValue {
  @usableFromInline
  internal init(_ rawAddress: UnsafeMutablePointer<yyjson_mut_val>, _ document: MutableJSON) {
    self.rawAddress = rawAddress
    self.document = document
  }

  /// yyjson_mut_val pointer
  @usableFromInline
  internal let rawAddress: UnsafeMutablePointer<yyjson_mut_val>

  public let document: MutableJSON
}

extension MutableJSONValue {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    unsafe_yyjson_mut_equals(lhs.rawAddress, rhs.rawAddress)
  }

  public struct Array: RawRepresentable {
    public init?(rawValue: MutableJSONValue) {
      guard rawValue.isArray else {
        return nil
      }
      self.rawValue = rawValue
    }
    public let rawValue: MutableJSONValue
  }

  public struct Object: RawRepresentable {
    public init?(rawValue: MutableJSONValue) {
      guard rawValue.isObject else {
        return nil
      }
      self.rawValue = rawValue
    }
    public let rawValue: MutableJSONValue
  }

  @inlinable
  public subscript(index: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(rawAddress, index)
      .map { .init($0, document) }
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_mut_get_type_desc(rawAddress))
  }

  @inlinable
  public var isRaw: Bool {
    unsafe_yyjson_is_raw(rawAddress)
  }

  @inlinable
  public var isNull: Bool {
    unsafe_yyjson_is_null(rawAddress)
  }

  @inlinable
  public var isTrue: Bool {
    unsafe_yyjson_is_true(rawAddress)
  }

  @inlinable
  public var isFalse: Bool {
    unsafe_yyjson_is_false(rawAddress)
  }

  @inlinable
  public var isBool: Bool {
    unsafe_yyjson_is_bool(rawAddress)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    unsafe_yyjson_is_uint(rawAddress)
  }

  @inlinable
  public var isSignedInteger: Bool {
    unsafe_yyjson_is_sint(rawAddress)
  }

  @inlinable
  public var isInteger: Bool {
    unsafe_yyjson_is_int(rawAddress)
  }

  @inlinable
  public var isDouble: Bool {
    unsafe_yyjson_is_real(rawAddress)
  }

  @inlinable
  public var isNumber: Bool {
    unsafe_yyjson_is_num(rawAddress)
  }

  @inlinable
  public var isString: Bool {
    unsafe_yyjson_is_str(rawAddress)
  }

  @inlinable
  public var isArray: Bool {
    unsafe_yyjson_is_arr(rawAddress)
  }

  @inlinable
  public var isObject: Bool {
    unsafe_yyjson_is_obj(rawAddress)
  }

  @inlinable
  public var isContainer: Bool {
    unsafe_yyjson_is_ctn(rawAddress)
  }

  @inlinable
  public func unsafeSetNull() {
    unsafe_yyjson_set_null(rawAddress)
  }

  @inlinable
  public var unsafeBool: Bool {
    get {
      unsafe_yyjson_get_bool(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_bool(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeUInt64: UInt64 {
    get {
      unsafe_yyjson_get_uint(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_uint(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeInt64: Int64 {
    get {
      unsafe_yyjson_get_sint(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_sint(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeDouble: Double {
    get {
      unsafe_yyjson_get_real(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_real(rawAddress, newValue)
    }
  }

  @inlinable
  public var unsafeNumber: Double {
    get {
      unsafe_yyjson_get_num(rawAddress)
    }
  }

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
    unsafe_yyjson_get_len(rawAddress)
  }

  @inlinable
  public func equals(toString buffer: UnsafeRawBufferPointer) -> Bool {
    unsafe_yyjson_equals_strn(rawAddress, buffer.baseAddress, buffer.count)
  }

  @inlinable
  public func set(fpToFloat: Bool) {
    yyjson_mut_set_fp_to_float(rawAddress, fpToFloat)
  }

  @inlinable
  public func set(prec: CInt) {
    yyjson_mut_set_fp_to_fixed(rawAddress, prec)
  }

  @inlinable
  public func set(noesc: Bool) {
    yyjson_mut_set_str_noesc(rawAddress, noesc)
  }

  @inlinable
  public func writeNumber(to string: UnsafeMutablePointer<CChar>) {
    yyjson_mut_write_number(rawAddress, string)
  }
}


extension MutableJSONValue.Array {

  @inlinable
  public init() {
    fatalError()
//    let doc = MutableJSON()!
//    self = doc.createArray()!.array!
  }

  @inlinable
  public func insert(_ newElement: MutableJSONValue, at i: Int) {
    assertSameDocument(newElement)
    precondition(yyjson_mut_arr_insert(rawValue.rawAddress, newElement.rawAddress, i))
  }

  @inlinable
  public func append(_ newElement: MutableJSONValue) {
    assertSameDocument(newElement)
    yyjson_mut_arr_append(rawValue.rawAddress, newElement.rawAddress)
  }

  @inlinable
  public func remove(at i: Int) -> MutableJSONValue {
    .init(yyjson_mut_arr_remove(rawValue.rawAddress, i), rawValue.document)
  }

  @inlinable
  public func removeFirst() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_first(rawValue.rawAddress), rawValue.document)
  }

  @inlinable
  public func removeLast() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_last(rawValue.rawAddress), rawValue.document)
  }

  @inlinable
  public func removeAll(keepingCapacity keepCapacity: Bool) {
    yyjson_mut_arr_clear(rawValue.rawAddress)
  }

  @inlinable
  public func removeSubrange(_ bounds: Range<Int>) {
    yyjson_mut_arr_remove_range(rawValue.rawAddress, bounds.lowerBound, bounds.upperBound)
  }

  @inlinable
  public func rotate(at i: Int) -> Bool {
    yyjson_mut_arr_rotate(rawValue.rawAddress, i)
  }

  @usableFromInline
  func assertSameDocument(_ v: MutableJSONValue) {
    assert(v.document === rawValue.document)
  }

  public func value(at idx: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(rawValue.rawAddress, idx)
      .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public subscript(position: Int) -> MutableJSONValue {
    get {
//      assert(indices.contains(position))
      return value(at: position).unsafelyUnwrapped
    }
    set {
//      assert(indices.contains(position))
      assertSameDocument(newValue)
      precondition(yyjson_mut_arr_replace(rawValue.rawAddress, position, newValue.rawAddress) != nil)
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator {
    @usableFromInline
    internal init(_ array: MutableJSONValue) {
      assert(array.isArray)
      self.array = array
      self.iter = .init()
    }

    @usableFromInline
    internal let array: MutableJSONValue

    @usableFromInline
    internal var iter: yyjson_mut_arr_iter

    @inlinable
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_mut_arr_iter_has_next)
    }

    @inlinable
    public mutating func reset() {
      yyjson_mut_arr_iter_init(array.rawAddress, &iter)
    }

    @inlinable
    public mutating func removeCurrent() -> MutableJSONValue? {
      yyjson_mut_arr_iter_remove(&iter)
        .map { MutableJSONValue($0, array.document) }
    }

    @inlinable
    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val, array.document)
      }
      return nil
    }

  }

  @inlinable
  public var first: MutableJSONValue? {
    yyjson_mut_arr_get_first(rawValue.rawAddress)
      .map { .init($0, rawValue.document) }
  }

  @inlinable
  public var last: MutableJSONValue? {
    yyjson_mut_arr_get_last(rawValue.rawAddress)
      .map { .init($0, rawValue.document) }
  }
}

extension MutableJSONValue.Object {
  public func value(for keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_obj_getn(rawValue.rawAddress, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init($0, rawValue.document) }
  }

  @inlinable
  public func add(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_add(self.rawValue.rawAddress, key.rawAddress, value.rawAddress))
  }

  @inlinable
  public func put(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_put(self.rawValue.rawAddress, key.rawAddress, value.rawAddress))
  }

  @inlinable
  public func rename(key: some ContiguousUTF8Bytes, newKey: some ContiguousUTF8Bytes) -> Bool {
    key.withContiguousUTF8Bytes { key in
      newKey.withContiguousUTF8Bytes { newKey in
        yyjson_mut_obj_rename_keyn(rawValue.document.rawAddress, rawValue.rawAddress, key.baseAddress, key.count, newKey.baseAddress, newKey.count)
      }
    }
  }

  @inlinable
  public func removeAll(key: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_obj_remove(rawValue.rawAddress, key.rawAddress)
      .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func removeAll(string: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    string.withContiguousUTF8Bytes { keyBuffer in
      yyjson_mut_obj_remove_strn(rawValue.rawAddress, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func removeAll(key: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    key.withContiguousUTF8Bytes { keyBuffer in
      yyjson_mut_obj_remove_keyn(rawValue.rawAddress, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func clear() {
    let success = yyjson_mut_obj_clear(rawValue.rawAddress)
    assert(success)
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator {
    @usableFromInline
    internal init(_ object: MutableJSONValue) {
      assert(object.isObject)
      self.object = object
      self.iter = .init()
    }

    @usableFromInline
    internal let object: MutableJSONValue

    @usableFromInline
    internal var iter: yyjson_mut_obj_iter

    @inlinable
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_mut_obj_iter_has_next)
    }

    @inlinable
    public func value(for key: MutableJSONValue) -> MutableJSONValue {
      .init(yyjson_mut_obj_iter_get_val(key.rawAddress), object.document)
    }

    @inlinable
    public mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
      yyjson_mut_obj_iter_getn(&iter, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init($0, object.document) }
    }

    @inlinable
    public mutating func reset() {
      yyjson_mut_obj_iter_init(object.rawAddress, &iter)
    }

    @inlinable
    public mutating func removeCurrent() -> MutableJSONValue? {
      yyjson_mut_obj_iter_remove(&iter)
        .map { MutableJSONValue($0, object.document) }
    }

    @inlinable
    public mutating func next() -> MutableJSONValue? {
      yyjson_mut_obj_iter_next(&iter)
        .map { MutableJSONValue($0, object.document) }
    }

  }
}

