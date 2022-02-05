import yyjson
import Precondition

public protocol JSONWriter {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws
}

extension JSONWriter {
  @_alwaysEmitIntoClient
  func write(options: JSON.WriteOptions) throws -> String {
    var length = 0
    let str = try write(options: options, length: &length, allocator: nil)
    defer {
      free(str)
    }
    return String(decoding: UnsafeRawBufferPointer(UnsafeMutableBufferPointer.init(start: str, count: length)), as: UTF8.self)
  }
}

extension JSON: JSONWriter {
  @_alwaysEmitIntoClient
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_write_opts(doc, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @_alwaysEmitIntoClient
  public func write(toFile path: UnsafePointer<CChar>, options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_write_file(path, doc, options.rawValue, allocator, &err)
    }
    if !succ {
      throw JSONWriteError(err)
    }
  }
}

extension MutableJSON: JSONWriter {
  @_alwaysEmitIntoClient
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_write_opts(doc, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @_alwaysEmitIntoClient
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_write_file(path, doc, options.rawValue, allocator, &err)
    }
    if !succ {
      throw JSONWriteError(err)
    }
  }
}
