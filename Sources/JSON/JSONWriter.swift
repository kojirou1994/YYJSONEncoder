import yyjson

public protocol JSONWriter {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) throws -> UnsafeMutablePointer<CChar>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) throws
}

extension JSON: JSONWriter {
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    guard let str = yyjson_write_opts(doc, options.rawValue, nil, length, &err) else {
      throw JSONWriteError(err: err)
    }
    return str
  }

  public func write(toFile path: UnsafePointer<CChar>, options: WriteOptions, length: UnsafeMutablePointer<Int>?) throws {
    var err = yyjson_write_err()
    if !yyjson_write_file(path, doc, options.rawValue, nil, &err) {
      throw JSONWriteError(err: err)
    }
  }
}

extension MutableJSON: JSONWriter {
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    guard let str = yyjson_mut_write_opts(doc, options.rawValue, nil, length, &err) else {
      throw JSONWriteError(err: err)
    }
    return str
  }

  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?) throws {
    var err = yyjson_write_err()
    if !yyjson_mut_write_file(path, doc, options.rawValue, nil, &err) {
      throw JSONWriteError(err: err)
    }
  }
}
