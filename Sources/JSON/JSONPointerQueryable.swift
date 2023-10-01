import yyjson

public protocol JSONPointerQueryable {
  associatedtype QueuryResult: JSONValueProtocol
  func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> QueuryResult?
}

extension JSON: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> JSONValue? {
    yyjson_doc_ptr_getn(docPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { JSONValue($0, self) }
  }
}

extension MutableJSON: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_doc_ptr_getn(docPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, self) }
  }
}

extension JSONValue: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> JSONValue? {
    yyjson_ptr_getn(valPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, document) }
  }
}

extension MutableJSONValue: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_ptr_getn(valPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, document) }
  }
}

extension JSONPointerQueryable {
  @inlinable
  public func query(jsonPointer: some StringProtocol) -> QueuryResult? {
    jsonPointer.withCStringBuffer(query(jsonPointerBuffer:))
  }
}
