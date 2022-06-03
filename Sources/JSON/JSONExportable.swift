import yyjson
import Precondition
import CUtility

public protocol JSONExportable {
  func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar>
  func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws
}

public extension JSONExportable {
  @inlinable
  func write(options: JSON.WriteOptions) throws -> LazyCopiedCString {
    var length = 0
    let str = try write(options: options, length: &length, allocator: nil)
    return .init(cString: str, forceLength: length, freeWhenDone: true)
  }
}

extension JSON: JSONExportable {
  @inlinable
  public func write(options: WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_write_opts(doc, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @inlinable
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

extension MutableJSON: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_write_opts(doc, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @inlinable
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

extension JSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_val_write_opts(val, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_val_write_file(path, val, options.rawValue, allocator, &err)
    }
    if !succ {
      throw JSONWriteError(err)
    }
  }
}

extension MutableJSONValue: JSONExportable {
  @inlinable
  public func write(options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws -> UnsafeMutablePointer<CChar> {
    var err = yyjson_write_err()
    let str = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_val_write_opts(val, options.rawValue, allocator, length, &err)
    }
    return try str.unwrap(JSONWriteError(err))
  }

  @inlinable
  public func write(toFile path: UnsafePointer<CChar>, options: JSON.WriteOptions, length: UnsafeMutablePointer<Int>?, allocator: JSONAllocator?) throws {
    var err = yyjson_write_err()
    let succ = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_mut_val_write_file(path, val, options.rawValue, allocator, &err)
    }
    if !succ {
      throw JSONWriteError(err)
    }
  }
}
