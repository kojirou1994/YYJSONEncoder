import yyjson
import Precondition

public final class MutableJSON {
  internal init(_ doc: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.doc = doc
  }

  public init() throws {
    doc = try yyjson_mut_doc_new(nil).unwrap(JSONError.noMemory)
  }

  let doc: UnsafeMutablePointer<yyjson_mut_doc>

  deinit {
    yyjson_mut_doc_free(doc)
  }
}

public extension MutableJSON {

  // MARK: Mutable JSON Value Creation API

  func null() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_null(doc).unwrap(JSONError.noMemory), doc: self)
  }

  func bool(_ value: Bool) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_bool(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  func uint(_ value: UInt64) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_uint(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  func sint(_ value: Int64) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_sint(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  func double(_ value: Double) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_real(doc, value).unwrap(JSONError.noMemory), doc: self)
  }

  func string(_ value: UnsafeBufferPointer<UInt8>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_strn(doc, .init(OpaquePointer(value.baseAddress)), value.count).unwrap(JSONError.noMemory), doc: self)
  }

  func string<T: StringProtocol>(_ value: T) throws -> MutableJSONValue {
    try value.utf8.withContiguousBuffer { buffer in
      MutableJSONValue(val: try yyjson_mut_strncpy(doc, .init(OpaquePointer(buffer.baseAddress)), buffer.count).unwrap(JSONError.noMemory), doc: self)
    }
  }

  // MARK: Mutable JSON Array Creation API
  func array() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr(doc).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Bool>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_bool(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Int8>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint8(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Int16>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint16(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Int32>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint32(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Int64>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_sint64(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<UInt8>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint8(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<UInt16>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint16(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<UInt32>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint32(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<UInt64>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_uint64(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Float>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_float(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  func array(values: UnsafeBufferPointer<Double>) throws -> MutableJSONValue {
    .init(val: try yyjson_mut_arr_with_double(doc, values.baseAddress, values.count).unwrap(JSONError.noMemory), doc: self)
  }

  // MARK: Mutable JSON Object Creation API

  func object() throws -> MutableJSONValue {
    .init(val: try yyjson_mut_obj(doc).unwrap(JSONError.noMemory), doc: self)
  }
}

public extension MutableJSON {

  var root: MutableJSONValue {
    get {
      .init(val: yyjson_mut_doc_get_root(doc), doc: self)
    }
    set {
      assert(newValue.doc === self)
      yyjson_mut_doc_set_root(doc, newValue.rawJSONValue.mutValPtr)
    }
  }

  func copy(value: JSONValue) throws -> MutableJSONValue {
    .init(val: try yyjson_val_mut_copy(doc, value.rawJSONValue.valPtr).unwrap(JSONError.noMemory), doc: self)
  }

}

public extension JSON {
  func copyMutable() throws -> MutableJSON {
    .init(try yyjson_doc_mut_copy(doc, nil).unwrap(JSONError.noMemory))
  }
}
