import yyjson
import CUtility

public protocol JSONExportable {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError>
  func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError>
}

public extension JSONExportable {
  @inlinable
  func write(options: JSON.WriteOptions) throws(JSONWriteError) -> DynamicCStringWithLength {
    var length = 0
    let cstr = try write(options: options, length: &length, allocator: nil).get()
    return .init(cString: .init(cString: cstr), forceLength: length)
  }
}

extension JSON: JSONExportable {
  @inlinable
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_write_opts(docPointer, options.rawValue, allocator, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_write_file(path, docPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @inlinable
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_write_fp(fp, docPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSON: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_mut_write_opts(docPointer, options.rawValue, allocator, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_write_file(path, docPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @inlinable
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_write_fp(fp, docPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension JSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_val_write_opts(valPointer, options.rawValue, allocator, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_val_write_file(path, valPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @inlinable
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_val_write_fp(fp, valPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_mut_val_write_opts(valPointer, options.rawValue, allocator, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_val_write_file(path, valPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @inlinable
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: UnsafePointer<JSONAllocator>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_val_write_fp(fp, valPointer, options.rawValue, allocator, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}
