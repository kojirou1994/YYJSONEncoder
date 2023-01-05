import yyjson
import Precondition

public final class MutableJSON {
  @usableFromInline
  internal init(_ docPointer: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.docPointer = docPointer
  }

  @inlinable
  public init?(allocator: JSONAllocator? = nil) {
    guard let docPointer = withOptionalAllocatorPointer(to: allocator, { allocator in
      yyjson_mut_doc_new(allocator)
    }) else {
      return nil
    }
    self.docPointer = docPointer
  }

  @usableFromInline
  internal let docPointer: UnsafeMutablePointer<yyjson_mut_doc>

  @inlinable
  deinit {
    yyjson_mut_doc_free(docPointer)
  }
}

public extension MutableJSON {

  // MARK: Mutable JSON Value Creation API

  @inlinable
  func createNull() -> MutableJSONValue? {
    yyjson_mut_null(docPointer).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Bool) -> MutableJSONValue? {
    yyjson_mut_bool(docPointer, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: UInt64) -> MutableJSONValue? {
    yyjson_mut_uint(docPointer, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Int64) -> MutableJSONValue? {
    yyjson_mut_sint(docPointer, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Double) -> MutableJSONValue? {
    yyjson_mut_real(docPointer, value).map { .init($0, self) }
  }

  @inlinable
  func create(stringNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_strn(docPointer, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: some StringProtocol) -> MutableJSONValue? {
    value.withCStringBuffer { buffer in
      yyjson_mut_strncpy(docPointer, buffer.baseAddress, buffer.count)
        .map { MutableJSONValue($0, self) }
    }
  }

  @inlinable
  func create(rawNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_rawn(docPointer, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(raw value: some StringProtocol) -> MutableJSONValue? {
    value.withCStringBuffer { buffer in
      yyjson_mut_rawncpy(docPointer, buffer.baseAddress, buffer.count)
        .map { MutableJSONValue($0, self) }
    }
  }

  // MARK: Mutable JSON Array Creation API
  @inlinable
  func createArray() -> MutableJSONValue? {
    yyjson_mut_arr(docPointer).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Bool>) -> MutableJSONValue? {
    yyjson_mut_arr_with_bool(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint8(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint16(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint32(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint64(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint8(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint16(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint32(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint64(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Float>) -> MutableJSONValue? {
    yyjson_mut_arr_with_float(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Double>) -> MutableJSONValue? {
    yyjson_mut_arr_with_double(docPointer, values.baseAddress, values.count).map { .init($0, self) }
  }

  // MARK: Mutable JSON Object Creation API

  @inlinable
  func createObject() -> MutableJSONValue? {
    yyjson_mut_obj(docPointer).map { .init($0, self) }
  }
}

public extension MutableJSON {

  @inlinable
  var root: MutableJSONValue? {
    get {
      yyjson_mut_doc_get_root(docPointer)
        .map { MutableJSONValue($0, self) }
    }
    set {
      assert(newValue == nil || newValue?.document === self)
      yyjson_mut_doc_set_root(docPointer, newValue?.valPointer)
    }
  }

  @inlinable
  func copy(value: JSONValue) -> MutableJSONValue? {
    yyjson_val_mut_copy(docPointer, value.valPointer).map { .init($0, self) }
  }

  @inlinable
  func copy(value: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_val_mut_copy(docPointer, value.valPointer).map { .init($0, self) }
  }

  @inlinable
  func mergePatched(original: JSONValue, patch: JSONValue) -> MutableJSONValue? {
    yyjson_merge_patch(docPointer, original.valPointer, patch.valPointer).map { .init($0, self) }
  }

}

// MARK: Document Convertions

public extension JSON {
  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) -> MutableJSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_doc_mut_copy(docPointer, allocator).map(MutableJSON.init)
    }
  }
}

public extension MutableJSON {

  @inlinable
  func copy(allocator: JSONAllocator? = nil) -> JSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_doc_imut_copy(docPointer, allocator).map(JSON.init)
    }
  }

  @inlinable
  func copyMutable(allocator: JSONAllocator? = nil) -> MutableJSON? {
    withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_doc_mut_copy(docPointer, allocator).map(MutableJSON.init)
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
