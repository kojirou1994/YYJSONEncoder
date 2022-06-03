import yyjson
import CUtility

public struct MutableJSONValue {
  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_mut_val>, doc: MutableJSON) {
    self.val = val
    self.doc = doc
  }

  @usableFromInline
  internal let val: UnsafeMutablePointer<yyjson_mut_val>

  @usableFromInline
  internal let doc: MutableJSON
}

extension MutableJSONValue: MutableJSONValueProtocol {

  @inlinable
  public static func == (lhs: MutableJSONValue, rhs: MutableJSONValue) -> Bool {
    yyjson_mut_equals(lhs.val, rhs.val)
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

  public struct Array {
    @usableFromInline
    internal init(value: MutableJSONValue) {
      assert(value.isArray)
      self.value = value
    }

    @usableFromInline
    let value: MutableJSONValue
  }
  public struct Object {
    @usableFromInline
    internal init(value: MutableJSONValue) {
      assert(value.isObject)
      self.value = value
    }

    @usableFromInline
    let value: MutableJSONValue
  }

  @inlinable
  public func value(withPointer pointer: String) -> MutableJSONValue {
    .init(val: yyjson_mut_get_pointer(val, pointer), doc: doc)
  }

  @inlinable
  public subscript(index: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(val, index).map { .init(val: $0, doc: doc) }
  }

  @inlinable
  public var typeDescription: StaticCString {
    .init(cString: yyjson_mut_get_type_desc(val))
  }

  @inlinable
  public var isRaw: Bool {
    yyjson_mut_is_raw(val)
  }

  @inlinable
  public var isNull: Bool {
    yyjson_mut_is_null(val)
  }

  @inlinable
  public var isTrue: Bool {
    yyjson_mut_is_true(val)
  }

  @inlinable
  public var isFalse: Bool {
    yyjson_mut_is_false(val)
  }

  @inlinable
  public var isBool: Bool {
    yyjson_mut_is_bool(val)
  }

  @inlinable
  public var isUnsignedInteger: Bool {
    yyjson_mut_is_uint(val)
  }

  @inlinable
  public var isSignedInteger: Bool {
    yyjson_mut_is_sint(val)
  }

  @inlinable
  public var isInteger: Bool {
    yyjson_mut_is_int(val)
  }

  @inlinable
  public var isDouble: Bool {
    yyjson_mut_is_real(val)
  }

  @inlinable
  public var isNumber: Bool {
    yyjson_mut_is_num(val)
  }

  @inlinable
  public var isString: Bool {
    yyjson_mut_is_str(val)
  }

  @inlinable
  public var isArray: Bool {
    yyjson_mut_is_arr(val)
  }

  @inlinable
  public var isObject: Bool {
    yyjson_mut_is_obj(val)
  }

  @inlinable
  public var isContainer: Bool {
    yyjson_mut_is_ctn(val)
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
  public func equals(toString buffer: UnsafeRawBufferPointer) -> Bool {
    yyjson_mut_equals_strn(val, buffer.baseAddress, buffer.count)
  }

}


extension MutableJSONValue.Array: RangeReplaceableCollection, MutableCollection, BidirectionalCollection {

  @inlinable
  public init() {
    let doc = try! MutableJSON()
    self = try! doc.array().array!
  }

  @inlinable
  public func index(before i: Int) -> Int {
    i - 1
  }

  @inlinable
  public func index(after i: Int) -> Int {
    i + 1
  }

  @inlinable
  public func insert(_ newElement: MutableJSONValue, at i: Int) {
    checkSameDoc(newElement)
    precondition(yyjson_mut_arr_insert(value.val, newElement.val, i))
  }

  @inlinable
  public func append(_ newElement: MutableJSONValue) {
    checkSameDoc(newElement)
    precondition(yyjson_mut_arr_append(value.val, newElement.val))
  }

  @inlinable
  public func remove(at i: Int) -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove(value.val, i), doc: value.doc)
  }

  @inlinable
  public func removeFirst() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_first(value.val), doc: value.doc)
  }

  @inlinable
  public func removeLast() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_last(value.val), doc: value.doc)
  }

  @inlinable
  public func removeAll(keepingCapacity keepCapacity: Bool) {
    precondition(yyjson_mut_arr_clear(value.val))
  }

  @inlinable
  public func removeSubrange(_ bounds: Range<Int>) {
    precondition(yyjson_mut_arr_remove_range(value.val, bounds.lowerBound, bounds.upperBound))
  }

  @inlinable
  public func rotate(at i: Int) -> Bool {
    yyjson_mut_arr_rotate(value.val, i)
  }

  @inlinable
  public var count: Int {
    yyjson_mut_arr_size(value.val)
  }

  @inlinable
  public var startIndex: Int {
    0
  }

  @inlinable
  public var endIndex: Int {
    count
  }

  @usableFromInline
  func checkSameDoc(_ v: MutableJSONValue) {
    assert(v.doc === value.doc)
  }

  @inlinable
  public subscript(position: Int) -> MutableJSONValue {
    get {
      precondition(0..<count ~= position)
      return .init(val: yyjson_mut_arr_get(value.val, position), doc: value.doc)
    }
    set {
      precondition(0..<count ~= position)
      checkSameDoc(newValue)
      precondition(yyjson_mut_arr_replace(value.val, position, newValue.val) != nil)
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_arr_iter = .init()
    yyjson_mut_arr_iter_init(value.val, &iter)
    return .init(array: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal init(array: MutableJSONValue, iter: yyjson_mut_arr_iter) {
      self.array = array
      self.iter = iter
    }

    @usableFromInline
    let array: MutableJSONValue

    @usableFromInline
    var iter: yyjson_mut_arr_iter

    @inlinable
    public mutating func hasNext() -> Bool {
      yyjson_mut_arr_iter_has_next(&iter)
    }

    @inlinable
    public mutating func removeCurrent() -> MutableJSONValue? {
      yyjson_mut_arr_iter_remove(&iter).map { MutableJSONValue(val: $0, doc: array.doc) }
    }

    @inlinable
    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

extension MutableJSONValue.Object: Sequence, JSONObjectProtocol {

  @inlinable
  public var count: Int {
    yyjson_mut_obj_size(value.val)
  }

  @inlinable
  public var underestimatedCount: Int { count }

  public subscript(keyBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_obj_getn(value.val, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init(val: $0, doc: value.doc) }
  }

  @inlinable
  public func add(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_add(value.val, key.val, value.val))
  }

  @inlinable
  public func put(key: MutableJSONValue, value: MutableJSONValue) {
    precondition(yyjson_mut_obj_put(value.val, key.val, value.val))
  }

  @inlinable
  public func removeAll(key: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_obj_remove(value.val, key.val)
      .map { MutableJSONValue(val: $0, doc: value.doc) }
  }

  @inlinable
  public func removeAll<T: StringProtocol>(string: T) -> MutableJSONValue? {
    string.withCStringBuffer { keyBuffer in
      yyjson_mut_obj_remove_strn(value.val, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue(val: $0, doc: value.doc) }
  }

  @inlinable
  public func removeAll<T: StringProtocol>(key: T) -> MutableJSONValue? {
    key.withCStringBuffer { keyBuffer in
      yyjson_mut_obj_remove_keyn(value.val, keyBuffer.baseAddress, keyBuffer.count)
    }
    .map { MutableJSONValue(val: $0, doc: value.doc) }
  }

  @inlinable
  public func clear() {
    precondition(yyjson_mut_obj_clear(value.val))
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_obj_iter = .init()
    yyjson_mut_obj_iter_init(value.val, &iter)
    return .init(object: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal init(object: MutableJSONValue, iter: yyjson_mut_obj_iter) {
      self.object = object
      self.iter = iter
    }

    @usableFromInline
    internal let object: MutableJSONValue

    @usableFromInline
    internal var iter: yyjson_mut_obj_iter

    @inlinable
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

