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

  @export(implementation)
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

  @export(implementation)
  public subscript(index: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(rawAddress, index)
      .map { .init($0, document) }
  }

  @export(implementation)
  public var typeDescription: StaticCString {
    .init(cString: yyjson_mut_get_type_desc(rawAddress))
  }

  @export(implementation)
  public var isRaw: Bool {
    unsafe_yyjson_is_raw(rawAddress)
  }

  @export(implementation)
  public var isNull: Bool {
    unsafe_yyjson_is_null(rawAddress)
  }

  @export(implementation)
  public var isTrue: Bool {
    unsafe_yyjson_is_true(rawAddress)
  }

  @export(implementation)
  public var isFalse: Bool {
    unsafe_yyjson_is_false(rawAddress)
  }

  @export(implementation)
  public var isBool: Bool {
    unsafe_yyjson_is_bool(rawAddress)
  }

  @export(implementation)
  public var isUnsignedInteger: Bool {
    unsafe_yyjson_is_uint(rawAddress)
  }

  @export(implementation)
  public var isSignedInteger: Bool {
    unsafe_yyjson_is_sint(rawAddress)
  }

  @export(implementation)
  public var isInteger: Bool {
    unsafe_yyjson_is_int(rawAddress)
  }

  @export(implementation)
  public var isDouble: Bool {
    unsafe_yyjson_is_real(rawAddress)
  }

  @export(implementation)
  public var isNumber: Bool {
    unsafe_yyjson_is_num(rawAddress)
  }

  @export(implementation)
  public var isString: Bool {
    unsafe_yyjson_is_str(rawAddress)
  }

  @export(implementation)
  public var isArray: Bool {
    unsafe_yyjson_is_arr(rawAddress)
  }

  @export(implementation)
  public var isObject: Bool {
    unsafe_yyjson_is_obj(rawAddress)
  }

  @export(implementation)
  public var isContainer: Bool {
    unsafe_yyjson_is_ctn(rawAddress)
  }

  @export(implementation)
  public func unsafeSetNull() {
    unsafe_yyjson_set_null(rawAddress)
  }

  @export(implementation)
  public var unsafeBool: Bool {
    get {
      unsafe_yyjson_get_bool(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_bool(rawAddress, newValue)
    }
  }

  @export(implementation)
  public var unsafeUInt64: UInt64 {
    get {
      unsafe_yyjson_get_uint(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_uint(rawAddress, newValue)
    }
  }

  @export(implementation)
  public var unsafeInt64: Int64 {
    get {
      unsafe_yyjson_get_sint(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_sint(rawAddress, newValue)
    }
  }

  @export(implementation)
  public var unsafeDouble: Double {
    get {
      unsafe_yyjson_get_real(rawAddress)
    }
    nonmutating set {
      unsafe_yyjson_set_real(rawAddress, newValue)
    }
  }

  @export(implementation)
  public var unsafeNumber: Double {
    get {
      unsafe_yyjson_get_num(rawAddress)
    }
  }

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
    unsafe_yyjson_get_len(rawAddress)
  }

  @export(implementation)
  public func equals(toString buffer: UnsafeRawBufferPointer) -> Bool {
    unsafe_yyjson_equals_strn(rawAddress, buffer.baseAddress, buffer.count)
  }

  @export(implementation)
  public func set(fpToFloat: Bool) {
    yyjson_mut_set_fp_to_float(rawAddress, fpToFloat)
  }

  @export(implementation)
  public func set(prec: CInt) {
    yyjson_mut_set_fp_to_fixed(rawAddress, prec)
  }

  @export(implementation)
  public func set(noesc: Bool) {
    yyjson_mut_set_str_noesc(rawAddress, noesc)
  }

  @export(implementation)
  public func writeNumber(to string: UnsafeMutablePointer<CChar>) {
    yyjson_mut_write_number(rawAddress, string)
  }
}


extension MutableJSONValue.Array {

  @export(implementation)
  public init() {
    fatalError()
//    let doc = MutableJSON()!
//    self = doc.createArray()!.array!
  }

  @export(implementation)
  public func insert(_ newElement: MutableJSONValue, at i: Int) {
    assertSameDocument(newElement)
    precondition(yyjson_mut_arr_insert(rawValue.rawAddress, newElement.rawAddress, i))
  }

  @export(implementation)
  public func append(_ newElement: MutableJSONValue) {
    assertSameDocument(newElement)
    yyjson_mut_arr_append(rawValue.rawAddress, newElement.rawAddress)
  }

  @export(implementation)
  public func remove(at i: Int) -> MutableJSONValue {
    .init(yyjson_mut_arr_remove(rawValue.rawAddress, i), rawValue.document)
  }

  @export(implementation)
  public func removeFirst() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_first(rawValue.rawAddress), rawValue.document)
  }

  @export(implementation)
  public func removeLast() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_last(rawValue.rawAddress), rawValue.document)
  }

  @export(implementation)
  public func removeAll(keepingCapacity keepCapacity: Bool) {
    yyjson_mut_arr_clear(rawValue.rawAddress)
  }

  @export(implementation)
  public func removeSubrange(_ bounds: Range<Int>) {
    yyjson_mut_arr_remove_range(rawValue.rawAddress, bounds.lowerBound, bounds.upperBound)
  }

  @export(implementation)
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

  @export(implementation)
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

  @export(implementation)
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

    @export(implementation)
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_mut_arr_iter_has_next)
    }

    @export(implementation)
    public mutating func reset() {
      yyjson_mut_arr_iter_init(array.rawAddress, &iter)
    }

    @export(implementation)
    public mutating func removeCurrent() -> MutableJSONValue? {
      yyjson_mut_arr_iter_remove(&iter)
        .map { MutableJSONValue($0, array.document) }
    }

    @export(implementation)
    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val, array.document)
      }
      return nil
    }

  }

  @export(implementation)
  public var first: MutableJSONValue? {
    yyjson_mut_arr_get_first(rawValue.rawAddress)
      .map { .init($0, rawValue.document) }
  }

  @export(implementation)
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

  @export(implementation)
  public func add(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_add(self.rawValue.rawAddress, key.rawAddress, value.rawAddress))
  }

  @export(implementation)
  public func put(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_put(self.rawValue.rawAddress, key.rawAddress, value.rawAddress))
  }

  @export(implementation)
  public func rename(key: some ContiguousUTF8Bytes, newKey: some ContiguousUTF8Bytes) -> Bool {
    key.withContiguousUTF8Bytes { key in
      newKey.withContiguousUTF8Bytes { newKey in
        yyjson_mut_obj_rename_keyn(rawValue.document.rawAddress, rawValue.rawAddress, key.baseAddress, key.count, newKey.baseAddress, newKey.count)
      }
    }
  }

  @export(implementation)
  public func removeAll(key: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_obj_remove(rawValue.rawAddress, key.rawAddress)
      .map { MutableJSONValue($0, rawValue.document) }
  }

  @export(implementation)
  public func removeAll(string: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    string.withContiguousUTF8Bytes { keyBuffer in
      yyjson_mut_obj_remove_strn(rawValue.rawAddress, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @export(implementation)
  public func removeAll(key: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    key.withContiguousUTF8Bytes { keyBuffer in
      yyjson_mut_obj_remove_keyn(rawValue.rawAddress, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @export(implementation)
  public func clear() {
    let success = yyjson_mut_obj_clear(rawValue.rawAddress)
    assert(success)
  }

  @export(implementation)
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

    @export(implementation)
    public var hasNext: Bool {
      var copy = iter
      return withUnsafeMutablePointer(to: &copy, yyjson_mut_obj_iter_has_next)
    }

    @export(implementation)
    public func value(for key: MutableJSONValue) -> MutableJSONValue {
      .init(yyjson_mut_obj_iter_get_val(key.rawAddress), object.document)
    }

    @export(implementation)
    public mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
      yyjson_mut_obj_iter_getn(&iter, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init($0, object.document) }
    }

    @export(implementation)
    public mutating func reset() {
      yyjson_mut_obj_iter_init(object.rawAddress, &iter)
    }

    @export(implementation)
    public mutating func removeCurrent() -> MutableJSONValue? {
      yyjson_mut_obj_iter_remove(&iter)
        .map { MutableJSONValue($0, object.document) }
    }

    @export(implementation)
    public mutating func next() -> MutableJSONValue? {
      yyjson_mut_obj_iter_next(&iter)
        .map { MutableJSONValue($0, object.document) }
    }

  }
}

