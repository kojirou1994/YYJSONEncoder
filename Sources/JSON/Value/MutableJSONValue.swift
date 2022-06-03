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
  public subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> MutableJSONValue? {
    get {
      yyjson_mut_obj_getn(val, keyBuffer.baseAddress, keyBuffer.count)
        .map { .init(val: $0, doc: doc) }
    }
    nonmutating set {

    }
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

  // MARK: Value API

  @inlinable
  public var bool: Bool? {
    yyjson_mut_get_bool(val)
  }

  @inlinable
  public var uint64: UInt64? {
    yyjson_mut_get_uint(val)
  }

  @inlinable
  public var int64: Int64? {
    yyjson_mut_get_sint(val)
  }

  @inlinable
  public var double: Double? {
    yyjson_mut_get_real(val)
  }

  @inlinable
  public func withRawCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    guard let raw = yyjson_mut_get_raw(val) else {
      return nil
    }
    return try body(raw)
  }

  @inlinable
  public func withCStringIfAvailable<T>(_ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T? {
    guard let string = yyjson_mut_get_str(val) else {
      return nil
    }
    return try body(string)
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
  public var count: Int {
    yyjson_mut_get_len(value.val)
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
    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

extension MutableJSONValue.Object: Sequence {

  @inlinable
  public var count: Int {
    yyjson_mut_get_len(value.val)
  }

  @inlinable
  public var underestimatedCount: Int { count }

  @inlinable
  public subscript(key: String) -> MutableJSONValue? {
    value[key]
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

