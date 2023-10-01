import yyjson
import CUtility

public struct MutableJSONValue {
  @usableFromInline
  internal init(_ valPointer: UnsafeMutablePointer<yyjson_mut_val>, _ document: MutableJSON) {
    self.valPointer = valPointer
    self.document = document
  }

  /// yyjson_mut_val pointer
  @usableFromInline
  internal let valPointer: UnsafeMutablePointer<yyjson_mut_val>

  public let document: MutableJSON
}

extension MutableJSONValue: MutableJSONValueProtocol {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    unsafe_yyjson_mut_equals(lhs.valPointer, rhs.valPointer)
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
    yyjson_mut_arr_get(valPointer, index)
      .map { .init($0, document) }
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_mut_get_type_desc(valPointer))
  }

  @inlinable
  public var isRaw: Bool {
    unsafe_yyjson_is_raw(valPointer)
  }

  @inlinable
  public var isNull: Bool {
    unsafe_yyjson_is_null(valPointer)
  }

  @inlinable
  public var isTrue: Bool {
    unsafe_yyjson_is_true(valPointer)
  }

  @inlinable
  public var isFalse: Bool {
    unsafe_yyjson_is_false(valPointer)
  }

  @inlinable
  public var isBool: Bool {
    unsafe_yyjson_is_bool(valPointer)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    unsafe_yyjson_is_uint(valPointer)
  }

  @inlinable
  public var isSignedInteger: Bool {
    unsafe_yyjson_is_sint(valPointer)
  }

  @inlinable
  public var isInteger: Bool {
    unsafe_yyjson_is_int(valPointer)
  }

  @inlinable
  public var isDouble: Bool {
    unsafe_yyjson_is_real(valPointer)
  }

  @inlinable
  public var isNumber: Bool {
    unsafe_yyjson_is_num(valPointer)
  }

  @inlinable
  public var isString: Bool {
    unsafe_yyjson_is_str(valPointer)
  }

  @inlinable
  public var isArray: Bool {
    unsafe_yyjson_is_arr(valPointer)
  }

  @inlinable
  public var isObject: Bool {
    unsafe_yyjson_is_obj(valPointer)
  }

  @inlinable
  public var isContainer: Bool {
    unsafe_yyjson_is_ctn(valPointer)
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
  public var unsafeNumber: Double {
    get {
      unsafe_yyjson_get_num(valPointer)
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


extension MutableJSONValue.Array: JSONArrayProtocol, MutableCollection, RangeReplaceableCollection {

  @inlinable
  public init() {
    let doc = MutableJSON()!
    self = doc.createArray()!.array!
  }

  public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, MutableJSONValue == C.Element {
    removeSubrange(subrange)
    var currentIndex: Index
    if subrange.isEmpty {
      currentIndex = startIndex
    } else {
      currentIndex = subrange.lowerBound
    }
    newElements.forEach { newElement in
      insert(newElement, at: currentIndex)
      currentIndex += 1
    }
  }

  @inlinable
  public func insert(_ newElement: MutableJSONValue, at i: Int) {
    assertSameDocument(newElement)
    precondition(yyjson_mut_arr_insert(rawValue.valPointer, newElement.valPointer, i))
  }

  @inlinable
  public func append(_ newElement: MutableJSONValue) {
    assertSameDocument(newElement)
    yyjson_mut_arr_append(rawValue.valPointer, newElement.valPointer)
  }

  @inlinable
  public func remove(at i: Int) -> MutableJSONValue {
    .init(yyjson_mut_arr_remove(rawValue.valPointer, i), rawValue.document)
  }

  @inlinable
  public func removeFirst() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_first(rawValue.valPointer), rawValue.document)
  }

  @inlinable
  public func removeLast() -> MutableJSONValue {
    .init(yyjson_mut_arr_remove_last(rawValue.valPointer), rawValue.document)
  }

  @inlinable
  public func removeAll(keepingCapacity keepCapacity: Bool) {
    yyjson_mut_arr_clear(rawValue.valPointer)
  }

  @inlinable
  public func removeSubrange(_ bounds: Range<Int>) {
    yyjson_mut_arr_remove_range(rawValue.valPointer, bounds.lowerBound, bounds.upperBound)
  }

  @inlinable
  public func rotate(at i: Int) -> Bool {
    yyjson_mut_arr_rotate(rawValue.valPointer, i)
  }

  @usableFromInline
  func assertSameDocument(_ v: MutableJSONValue) {
    assert(v.document === rawValue.document)
  }

  public func value(at idx: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(rawValue.valPointer, idx)
      .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public subscript(position: Int) -> MutableJSONValue {
    get {
      assert(indices.contains(position))
      return value(at: position).unsafelyUnwrapped
    }
    set {
      assert(indices.contains(position))
      assertSameDocument(newValue)
      precondition(yyjson_mut_arr_replace(rawValue.valPointer, position, newValue.valPointer) != nil)
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator: JSONContainerIterator {
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
      yyjson_mut_arr_iter_init(array.valPointer, &iter)
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
    yyjson_mut_arr_get_first(rawValue.valPointer)
      .map { .init($0, rawValue.document) }
  }

  @inlinable
  public var last: MutableJSONValue? {
    yyjson_mut_arr_get_last(rawValue.valPointer)
      .map { .init($0, rawValue.document) }
  }
}

extension MutableJSONValue.Object: JSONObjectProtocol {
  public func value(for keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_obj_getn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init($0, rawValue.document) }
  }

  @inlinable
  public func add(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_add(self.rawValue.valPointer, key.valPointer, value.valPointer))
  }

  @inlinable
  public func put(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_put(self.rawValue.valPointer, key.valPointer, value.valPointer))
  }

  @inlinable
  public func rename(key: some StringProtocol, newKey: some StringProtocol) -> Bool {
    key.withCStringBuffer { key in
      newKey.withCStringBuffer { newKey in
        rename(key: key, newKey: newKey)
      }
    }
  }

  @inlinable
  public func rename(key: UnsafeRawBufferPointer, newKey: UnsafeRawBufferPointer) -> Bool {
    yyjson_mut_obj_rename_keyn(rawValue.document.docPointer, rawValue.valPointer, key.baseAddress, key.count, newKey.baseAddress, newKey.count)
  }

  @inlinable
  public func removeAll(key: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_obj_remove(rawValue.valPointer, key.valPointer)
      .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func removeAll<T: StringProtocol>(string: T) -> MutableJSONValue? {
    string.withCStringBuffer { keyBuffer in
      yyjson_mut_obj_remove_strn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func removeAll<T: StringProtocol>(key: T) -> MutableJSONValue? {
    key.withCStringBuffer { keyBuffer in
      yyjson_mut_obj_remove_keyn(rawValue.valPointer, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue($0, rawValue.document) }
  }

  @inlinable
  public func clear() {
    let success = yyjson_mut_obj_clear(rawValue.valPointer)
    assert(success)
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: Iterator = .init(rawValue)
    iter.reset()
    return iter
  }

  public struct Iterator: JSONObjectIterator {
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
      .init(yyjson_mut_obj_iter_get_val(key.valPointer), object.document)
    }

    @inlinable
    public mutating func itearate(to keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
      yyjson_mut_obj_iter_getn(&iter, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init($0, object.document) }
    }

    @inlinable
    public mutating func reset() {
      yyjson_mut_obj_iter_init(object.valPointer, &iter)
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

