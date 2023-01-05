import yyjson
import CUtility

public protocol JSONExportable {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<Void, JSONWriteError>
}

public extension JSONExportable {
  @inlinable
  func write(options: JSON.WriteOptions) -> Result<LazyCopiedCString, JSONWriteError> {
    var length = 0
    return write(options: options, length: &length, allocator: nil)
      .map { LazyCopiedCString(cString: $0, forceLength: length, freeWhenDone: true) }
  }
}

extension JSON: JSONExportable {
  @inlinable
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_write_opts(docPointer, options.rawValue, allocator, length, &err)
    }
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_write_file(path, docPointer, options.rawValue, allocator, &err)
    }
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSON: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_write_opts(docPointer, options.rawValue, allocator, length, &err)
    }
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_write_file(path, docPointer, options.rawValue, allocator, &err)
    }
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension JSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_val_write_opts(valPointer, options.rawValue, allocator, length, &err)
    }
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_val_write_file(path, valPointer, options.rawValue, allocator, &err)
    }
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_val_write_opts(valPointer, options.rawValue, allocator, length, &err)
    }
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_val_write_file(path, valPointer, options.rawValue, allocator, &err)
    }
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}
