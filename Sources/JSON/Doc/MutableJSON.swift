import yyjson
import CUtility
import Precondition

public final class MutableJSON {
  @usableFromInline
  internal init(_ rawAddress: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.rawAddress = rawAddress
  }

  @inlinable
  public init?() {
    guard let rawAddress = yyjson_mut_doc_new(nil) else {
      return nil
    }
    self.rawAddress = rawAddress
  }

  @usableFromInline
  internal let rawAddress: UnsafeMutablePointer<yyjson_mut_doc>

  @inlinable
  deinit {
    yyjson_mut_doc_free(rawAddress)
  }
}

public extension MutableJSON {

  // MARK: Mutable JSON Value Creation API

  @inlinable
  func createNull() -> MutableJSONValue? {
    yyjson_mut_null(rawAddress).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Bool) -> MutableJSONValue? {
    yyjson_mut_bool(rawAddress, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: UInt64) -> MutableJSONValue? {
    yyjson_mut_uint(rawAddress, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Int64) -> MutableJSONValue? {
    yyjson_mut_sint(rawAddress, value).map { .init($0, self) }
  }

  @inlinable
  func create(_ value: Double) -> MutableJSONValue? {
    yyjson_mut_real(rawAddress, value).map { .init($0, self) }
  }

  @inlinable
  func create(stringNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_strn(rawAddress, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(string value: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    value.withContiguousUTF8Bytes { buffer in
      yyjson_mut_strncpy(rawAddress, buffer.baseAddress, buffer.count)
    }.map { .init($0, self) }
  }

  @inlinable
  func create(rawNoCopy value: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_rawn(rawAddress, value.baseAddress, value.count).map { .init($0, self) }
  }

  @inlinable
  func create(raw value: some ContiguousUTF8Bytes) -> MutableJSONValue? {
    value.withContiguousUTF8Bytes { buffer in
      yyjson_mut_rawncpy(rawAddress, buffer.baseAddress, buffer.count)
    }.map { .init($0, self) }
  }

  // MARK: Mutable JSON Array Creation API
  @inlinable
  func createArray() -> MutableJSONValue? {
    yyjson_mut_arr(rawAddress).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Bool>) -> MutableJSONValue? {
    yyjson_mut_arr_with_bool(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint8(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint16(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint32(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Int64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_sint64(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt8>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint8(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt16>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint16(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt32>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint32(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<UInt64>) -> MutableJSONValue? {
    yyjson_mut_arr_with_uint64(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Float>) -> MutableJSONValue? {
    yyjson_mut_arr_with_float(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  @inlinable
  func createArray(values: UnsafeBufferPointer<Double>) -> MutableJSONValue? {
    yyjson_mut_arr_with_double(rawAddress, values.baseAddress, values.count).map { .init($0, self) }
  }

  // MARK: Mutable JSON Object Creation API

  @inlinable
  func createObject() -> MutableJSONValue? {
    yyjson_mut_obj(rawAddress).map { .init($0, self) }
  }
}

public extension MutableJSON {

  @inlinable
  var root: MutableJSONValue? {
    get {
      yyjson_mut_doc_get_root(rawAddress)
        .map { MutableJSONValue($0, self) }
    }
    set {
      assert(newValue == nil || newValue?.document === self)
      yyjson_mut_doc_set_root(rawAddress, newValue?.rawAddress)
    }
  }

  @inlinable
  func copy(value: borrowing JSONValue) -> MutableJSONValue? {
    yyjson_val_mut_copy(rawAddress, value.rawAddress).map { .init($0, self) }
  }

  @inlinable
  func copy(value: MutableJSONValue) -> MutableJSONValue? {
    yyjson_mut_val_mut_copy(rawAddress, value.rawAddress).map { .init($0, self) }
  }

  @inlinable
  func mergePatched(original: borrowing JSONValue, patch: borrowing JSONValue) -> MutableJSONValue? {
    yyjson_merge_patch(rawAddress, original.rawAddress, patch.rawAddress).map { .init($0, self) }
  }

}

// MARK: Document Convertions

public extension JSON {
  @inlinable
  func copyMutable() -> MutableJSON? {
    assert(root.exists)
    return yyjson_doc_mut_copy(rawAddress, nil).map(MutableJSON.init)
  }
}

public extension MutableJSON {

  @inlinable
  func copy() -> JSON? {
    assert(root != nil)
    return yyjson_mut_doc_imut_copy(rawAddress, nil).map(JSON.init)
  }

  @inlinable
  func copyMutable() -> MutableJSON? {
    assert(root != nil)
    return yyjson_mut_doc_mut_copy(rawAddress, nil).map(MutableJSON.init)
  }
}

public extension MutableJSONValue {
  /// Copies and returns a new immutable document. This makes a `deep-copy` on the mutable value.
  /// This function is recursive and may cause a stack overflow if the object level is too deep.
  @inlinable
  func copy() -> JSON? {
    yyjson_mut_val_imut_copy(rawAddress, nil).map(JSON.init)
  }
}
