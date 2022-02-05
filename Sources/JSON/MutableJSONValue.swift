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
  public var array: Array? {
    guard isArray else {
      return nil
    }
    return .init(value: self)
  }

  public var object: Object? {
    guard isObject else {
      return nil
    }
    return .init(value: self)
  }

  public struct Array {
    let value: MutableJSONValue
  }
  public struct Object {
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

  public init() {
    let doc = try! MutableJSON()
    self = try! doc.array().array!
  }

  public func index(before i: Int) -> Int {
    i - 1
  }

  public func index(after i: Int) -> Int {
    i + 1
  }

  public func insert(_ newElement: MutableJSONValue, at i: Int) {
    checkSameDoc(newElement)
    precondition(yyjson_mut_arr_insert(value.rawJSONValue.mutValPtr, newElement.rawJSONValue.mutValPtr, i))
  }

  public func append(_ newElement: MutableJSONValue) {
    checkSameDoc(newElement)
    precondition(yyjson_mut_arr_append(value.rawJSONValue.mutValPtr, newElement.rawJSONValue.mutValPtr))
  }

  public func remove(at i: Int) -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove(value.rawJSONValue.mutValPtr, i), doc: value.doc)
  }

  public func removeFirst() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_first(value.rawJSONValue.mutValPtr), doc: value.doc)
  }

  public func removeLast() -> MutableJSONValue {
    .init(val: yyjson_mut_arr_remove_last(value.rawJSONValue.mutValPtr), doc: value.doc)
  }

  public func removeAll(keepingCapacity keepCapacity: Bool) {
    precondition(yyjson_mut_arr_clear(value.rawJSONValue.mutValPtr))
  }

  public func removeSubrange(_ bounds: Range<Int>) {
    precondition(yyjson_mut_arr_remove_range(value.rawJSONValue.mutValPtr, bounds.lowerBound, bounds.upperBound))
  }

  public var count: Int {
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
  }

  public var startIndex: Int {
    0
  }

  public var endIndex: Int {
    count
  }

  @usableFromInline
  func checkSameDoc(_ v: MutableJSONValue) {
    precondition(v.doc === value.doc)
  }

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

  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_arr_iter = .init()
    yyjson_mut_arr_iter_init(value.rawJSONValue.mutValPtr, &iter)
    return .init(array: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let array: MutableJSONValue
    var iter: yyjson_mut_arr_iter

    public mutating func next() -> MutableJSONValue? {
      if let val = yyjson_mut_arr_iter_next(&iter) {
        return .init(val: val, doc: array.doc)
      }
      return nil
    }

  }
}

extension MutableJSONValue.Object: Sequence {

  public var count: Int {
    unsafe_yyjson_get_len(value.rawJSONValue.rawPtr)
  }

  public var underestimatedCount: Int { count }

  public subscript(key: String) -> MutableJSONValue? {
    value[key]
  }

  public func makeIterator() -> Iterator {
    var iter: yyjson_mut_obj_iter = .init()
    yyjson_mut_obj_iter_init(value.rawJSONValue.mutValPtr, &iter)
    return .init(object: value, iter: iter)
  }

  public struct Iterator: IteratorProtocol {

    let object: MutableJSONValue
    var iter: yyjson_mut_obj_iter

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

