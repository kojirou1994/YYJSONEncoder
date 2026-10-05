import yyjson
import CUtility

public protocol JSONExportable: ~Copyable, ~Escapable {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError>
  func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError>
}


extension JSON: JSONExportable {
  @export(implementation)
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_write_opts(rawAddress, options.rawValue, nil, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @export(implementation)
  public func write(toFile path: UnsafePointer<CChar>, options: WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_write_file(path, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @export(implementation)
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_write_fp(fp, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSON: JSONExportable {
  @export(implementation)
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_mut_write_opts(rawAddress, options.rawValue, nil, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @export(implementation)
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_write_file(path, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @export(implementation)
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_write_fp(fp, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension JSONValue: JSONExportable {
  @export(implementation)
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_val_write_opts(rawAddress, options.rawValue, nil, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @export(implementation)
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_val_write_file(path, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @export(implementation)
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_val_write_fp(fp, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}

extension MutableJSONValue: JSONExportable {
  @export(implementation)
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<UnsafeMutablePointer<CChar>, JSONWriteError> {
    var err = yyjson_write_err()
    let str = yyjson_mut_val_write_opts(rawAddress, options.rawValue, nil, length, &err)
    return str.map(Result.success) ?? .failure(JSONWriteError(err))
  }

  @export(implementation)
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_val_write_file(path, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }

  @export(implementation)
  public func write(toFile fp: UnsafeMutablePointer<FILE>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) -> Result<Void, JSONWriteError> {
    var err = yyjson_write_err()
    let succ = yyjson_mut_val_write_fp(fp, rawAddress, options.rawValue, nil, &err)
    if succ {
      return .success(())
    } else {
      return .failure(JSONWriteError(err))
    }
  }
}
