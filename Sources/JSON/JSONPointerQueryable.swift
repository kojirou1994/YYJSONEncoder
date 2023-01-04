import yyjson

public protocol JSONPointerQueryable {
  associatedtype QueuryResult: JSONValueProtocol
  func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> QueuryResult?
}

extension JSON: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> JSONValue? {
    yyjson_doc_get_pointern(doc, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { JSONValue($0, self) }
  }
}

extension MutableJSON: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_doc_get_pointern(doc, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, self) }
  }
}

extension JSONValue: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> JSONValue? {
    yyjson_get_pointern(valPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, document) }
  }
}

extension MutableJSONValue: JSONPointerQueryable {
  @inlinable
  public func query(jsonPointerBuffer: UnsafeRawBufferPointer) -> MutableJSONValue? {
    yyjson_mut_get_pointern(valPointer, jsonPointerBuffer.baseAddress, jsonPointerBuffer.count)
      .map { .init($0, document) }
  }
}

extension JSONPointerQueryable {
  @inlinable
  public func query(jsonPointer: some StringProtocol) -> QueuryResult? {
    jsonPointer.withCStringBuffer(query(jsonPointerBuffer:))
  }
}
