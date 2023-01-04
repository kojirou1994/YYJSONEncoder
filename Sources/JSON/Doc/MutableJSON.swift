import yyjson
import Precondition

public final class MutableJSON {
  @usableFromInline
  internal init(_ doc: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.doc = doc
  }

  @inlinable
  public init?(allocator: JSONAllocator? = nil) {
    guard let doc = withOptionalAllocatorPointer(to: allocator, { allocator in
      yyjson_mut_doc_new(allocator)
    }) else {
      return nil
    }
    self.doc = doc
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
  func createNull() -> MutableJSONValue? {
    yyjson_mut_null(doc).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Bool) -> MutableJSONValue? {
    yyjson_mut_bool(doc, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: UInt64) -> MutableJSONValue? {
    yyjson_mut_uint(doc, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Int64) -> MutableJSONValue? {
    yyjson_mut_sint(doc, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Double) -> MutableJSONValue? {
    yyjson_mut_real(doc, value).map { .init($0, self) }
  }

  @inlinable
  func create(stringNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_strn(doc, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: some StringProtocol) -> MutableJSONValue? {
    value.withCStringBuffer { buffer in
      yyjson_mut_strncpy(doc, buffer.baseAddress, buffer.count)
        .map { MutableJSONValue($0, self) }
    }
  }

  @inlinable
  func create(rawNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_rawn(doc, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(raw value: some StringProtocol) -> MutableJSONValue? {
    value.withCStringBuffer { buffer in
      yyjson_mut_rawncpy(doc, buffer.baseAddress, buffer.count)
        .map { MutableJSONValue($0, self) }
    }
  }

  // MARK: Mutable JSON Array Creation API
  @inlinable
  func createArray() -> MutableJSONValue? {
    yyjson_mut_arr(doc).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Bool>) -> MutableJSONValue? {
    yyjson_mut_arr_with_bool(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint8(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint16(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint32(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint64(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint8(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint16(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint32(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint64(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Float>) -> MutableJSONValue? {
    yyjson_mut_arr_with_float(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Double>) -> MutableJSONValue? {
    yyjson_mut_arr_with_double(doc, values.baseAddress, values.count).map { .init($0, self) }
  }

  // MARK: Mutable JSON Object Creation API

  @inlinable
  func createObject() -> MutableJSONValue? {
    yyjson_mut_obj(doc).map { .init($0, self) }
  }
}

public extension MutableJSON {

  @inlinable
  var root: MutableJSONValue? {
    get {
      yyjson_mut_doc_get_root(doc)
        .map { MutableJSONValue($0, self) }
    }
    set {
      assert(newValue == nil || newValue?.document === self)
      yyjson_mut_doc_set_root(doc, newValue?.valPointer)
    }
  }

  @inlinable
  func copy(value: JSONValue) -> MutableJSONValue? {
    yyjson_val_mut_copy(doc, value.valPointer).map { .init($0, self) }
  }

  @inlinable
  func copy(value: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_val_mut_copy(doc, value.valPointer).map { .init($0, self) }
  }

  @inlinable
  func mergePatched(original: JSONValue, patch: JSONValue) -> MutableJSONValue? {
    yyjson_merge_patch(doc, original.valPointer, patch.valPointer).map { .init($0, self) }
  }

}

// MARK: Document Convertions

public extension JSON {
  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) -> MutableJSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_doc_mut_copy(doc, allocator).map(MutableJSON.init)
    }
  }
}

public extension MutableJSON {

  @inlinable
  func copy(allocator: JSONAllocator? = nil) -> JSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_doc_imut_copy(doc, allocator).map(JSON.init)
    }
  }

  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) -> MutableJSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_doc_mut_copy(doc, allocator).map(MutableJSON.init)
    }
  }
}

public extension MutableJSONValue {
  /// Copies and returns a new immutable document. This makes a `deep-copy` on the mutable value.
  /// This function is recursive and may cause a stack overflow if the object level is too deep.
  @inlinable
  func copy(allocator: JSONAllocator? = nil) -> JSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_val_imut_copy(valPointer, allocator).map(JSON.init)
    }
  }
}
