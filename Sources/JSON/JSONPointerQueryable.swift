import yyjson

public protocol JSONPointerQueryable {
  associatedtype QueuryResult: JSONValueProtocol
  func value(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<QueuryResult, JSONPointerError>
}

public protocol JSONPointerSettable: JSONPointerQueryable {
  // TODO: output context
  func set(_ value: QueuryResult, byJSONPointer buffer: UnsafeRawBufferPointer, createParent: Bool) -> Result<Void, JSONPointerError>

  // TODO: output context
  func remove(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<QueuryResult, JSONPointerError>
}

extension JSON: JSONPointerQueryable {
  @inlinable
  public func value(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<JSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_doc_ptr_getx(docPointer, buffer.baseAddress, buffer.count, &err)
      .map { .success(.init($0, self)) } ?? .failure(.init(err))
  }
}

extension MutableJSON: JSONPointerSettable {
  @inlinable
  public func value(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<MutableJSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    // TODO: support context
    return yyjson_mut_doc_ptr_getx(docPointer, buffer.baseAddress, buffer.count, nil, &err)
      .map { .success(.init($0, self)) } ?? .failure(.init(err))
  }

  @inlinable
  public func set(_ value: MutableJSONValue, byJSONPointer buffer: UnsafeRawBufferPointer, createParent: Bool) -> Result<Void, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_mut_doc_ptr_setx(docPointer, buffer.baseAddress, buffer.count, value.valPointer, createParent, nil, &err) ? .success(()) : .failure(.init(err))
  }

  @inlinable
  public func remove(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<MutableJSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_mut_doc_ptr_removex(docPointer, buffer.baseAddress, buffer.count, nil, &err)
      .map { .success(.init($0, self)) } ?? .failure(.init(err))
  }
}

extension JSONValue: JSONPointerQueryable {
  @inlinable
  public func value(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<JSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_ptr_getx(valPointer, buffer.baseAddress, buffer.count, &err)
      .map { .success(.init($0, document)) } ?? .failure(.init(err))
  }
}

extension MutableJSONValue: JSONPointerSettable {
  @inlinable
  public func value(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<MutableJSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    // TODO: support context
    return yyjson_mut_ptr_getx(valPointer, buffer.baseAddress, buffer.count, nil, &err)
      .map { .success(.init($0, document)) } ?? .failure(.init(err))
  }

  @inlinable
  public func set(_ value: MutableJSONValue, byJSONPointer buffer: UnsafeRawBufferPointer, createParent: Bool) -> Result<Void, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_mut_ptr_setx(valPointer, buffer.baseAddress, buffer.count, value.valPointer, document.docPointer, createParent, nil, &err) ? .success(()) : .failure(.init(err))
  }

  @inlinable
  public func remove(byJSONPointer buffer: UnsafeRawBufferPointer) -> Result<MutableJSONValue, JSONPointerError> {
    var err = yyjson_ptr_err()
    return yyjson_mut_ptr_removex(valPointer, buffer.baseAddress, buffer.count, nil, &err)
      .map { .success(.init($0, document)) } ?? .failure(.init(err))
  }
}
