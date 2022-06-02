import yyjson

extension RawJSONValue {
  @usableFromInline
  var mutValPtr: UnsafeMutablePointer<yyjson_mut_val> {
    rawPtr.assumingMemoryBound(to: yyjson_mut_val.self)
  }
}

public struct MutableJSONValue {
  @usableFromInline
  internal init(val: UnsafeMutablePointer<yyjson_mut_val>, doc: MutableJSON) {
    self.rawJSONValue = .init(rawPtr: val)
    self.doc = doc
  }

  public let rawJSONValue: RawJSONValue

  @usableFromInline
  let doc: MutableJSON
}

extension MutableJSONValue: JSONValueProtocol {

  @inlinable
  public static func == (lhs: MutableJSONValue, rhs: MutableJSONValue) -> Bool {
    yyjson_mut_equals(lhs.rawJSONValue.mutValPtr, rhs.rawJSONValue.mutValPtr)
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
    .init(val: yyjson_mut_get_pointer(rawJSONValue.mutValPtr, pointer), doc: doc)
  }

  @inlinable
  public subscript(index: Int) -> MutableJSONValue? {
    yyjson_mut_arr_get(rawJSONValue.mutValPtr, index).map { .init(val: $0, doc: doc) }
  }

  @inlinable
  public subscript(keyBuffer: UnsafeBufferPointer<CChar>) -> MutableJSONValue? {
    yyjson_mut_obj_getn(rawJSONValue.mutValPtr, keyBuffer.baseAddress, keyBuffer.count)
      .map { .init(val: $0, doc: doc) }
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
    precondition(yyjson_mut_arr_insert(value.rawJSONValue.mutValPtr, newElement.rawJSONValue.mutValPtr, i))
  }

  @inlinable
  public func append(_ newElement: MutableJSONValue) {
    checkSameDoc(newElement)
    precondition(yyjson_mut_arr_append(value.rawJSONValue.mutValPtr, newElement.rawJSONValue.mutValPtr))
  }

  @inlinable
  public func remove(at i: Int) -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove(value.rawJSONValue.mutValPtr, i), doc: value.doc)
  }

  @inlinable
  public func removeFirst() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_first(value.rawJSONValue.mutValPtr), doc: value.doc)
  }

  @inlinable
  public func removeLast() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_last(value.rawJSONValue.mutValPtr), doc: value.doc)
  }

  @inlinable
  public func removeAll(keepingCapacity keepCapacity: Bool) {
    precondition(yyjson_mut_arr_clear(value.rawJSONValue.mutValPtr))
  }

  @inlinable
  public func removeSubrange(_ bounds: Range<Int>) {
    precondition(yyjson_mut_arr_remove_range(value.rawJSONValue.mutValPtr, bounds.lowerBound, bounds.upperBound))
  }

  @inlinable
  public var count: Int {
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
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
      return .init(val: yyjson_mut_arr_get(value.rawJSONValue.mutValPtr, position), doc: value.doc)
    }
    set {
      precondition(0..<count ~= position)
      checkSameDoc(newValue)
      precondition(yyjson_mut_arr_replace(value.rawJSONValue.mutValPtr, position, newValue.rawJSONValue.mutValPtr) != nil)
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_arr_iter = .init()
    yyjson_mut_arr_iter_init(value.rawJSONValue.mutValPtr, &iter)
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
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
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
    yyjson_mut_obj_iter_init(value.rawJSONValue.mutValPtr, &iter)
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

