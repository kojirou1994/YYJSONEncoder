import yyjson
import Precondition

public final class MutableJSON {
  @usableFromInline
  internal init(_ doc: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.doc = doc
  }

  @inlinable
  public init(allocator: JSONAllocator? = nil) throws {
    doc = try withOptionalAllocatorPointer(to: allocator) { allocator in
      try yyjson_mut_doc_new(allocator).unwrap(JSONError.noMemory)
    }
  }

  @usableFromInline
  internal let doc: UnsafeMutablePointer<yyjson_mut_doc>

  @inlinable
  deinit {
    yyjson_mut_doc_free(doc)
  }
}

public extension MutableJSON {

  // MARK: Mutable JSON Value Creation API

  @inlinable
  func createNull() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_null(doc).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create(_ value: Bool) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_bool(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create(_ value: UInt64) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_uint(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create(_ value: Int64) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_sint(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create(_ value: Double) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_real(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create(stringNoCopy value: UnsafeRawBufferPointer) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_strn(doc, value.baseAddress, value.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create<T: StringProtocol>(_ value: T) throws -> MutableJSONValue {
    try value.withCStringBuffer { buffer in
      MutableJSONValue(val: try yyjson_mut_strncpy(doc, buffer.baseAddress, buffer.count).unwrap(JSONError.noMemory), doc: self)
    }
  }

  @inlinable
  func create(rawNoCopy value: UnsafeRawBufferPointer) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_rawn(doc, value.baseAddress, value.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func create<T: StringProtocol>(raw value: T) throws -> MutableJSONValue {
    try value.withCStringBuffer { buffer in
      MutableJSONValue(val: try yyjson_mut_rawncpy(doc, buffer.baseAddress, buffer.count).unwrap(JSONError.noMemory), doc: self)
    }
  }

  // MARK: Mutable JSON Array Creation API
  @inlinable
  func createArray() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr(doc).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Bool>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_bool(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int8>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint8(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int16>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint16(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int32>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint32(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int64>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint64(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt8>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint8(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt16>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint16(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt32>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint32(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt64>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint64(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Float>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_float(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Double>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_double(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  // MARK: Mutable JSON Object Creation API

  @inlinable
  func createObject() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_obj(doc).unwrap(JSONError.noMemory), doc: self)
  }
}

public extension MutableJSON {

  @inlinable
  var root: MutableJSONValue? {
    get {
      yyjson_mut_doc_get_root(doc).map { MutableJSONValue(val: $0, doc: self) }
    }
    set {
      assert(newValue == nil || newValue?.doc === self)
      yyjson_mut_doc_set_root(doc, newValue?.val)
    }
  }

  @inlinable
  func copy(value: JSONValue) throws -> MutableJSONValue {
    .init(val: try yyjson_val_mut_copy(doc, value.val).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func copy(value: MutableJSONValue) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_val_mut_copy(doc, value.val).unwrap(JSONError.noMemory), doc: self)
  }

  @inlinable
  func mergePatched(original: JSONValue, patch: JSONValue) throws -> MutableJSONValue {
    .init(val: try yyjson_merge_patch(doc, original.val, patch.val).unwrap(JSONError.noMemory), doc: self)
  }

}

public extension JSON {
  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) throws -> MutableJSON {
    try withOptionalAllocatorPointer(to: allocator) { allocator in
      try MutableJSON(yyjson_doc_mut_copy(doc, allocator).unwrap(JSONError.noMemory))
    }
  }
}

public extension MutableJSON {
  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) throws -> MutableJSON {
    try withOptionalAllocatorPointer(to: allocator) { allocator in
      try MutableJSON(yyjson_mut_doc_mut_copy(doc, allocator).unwrap(JSONError.noMemory))
    }
  }
}
