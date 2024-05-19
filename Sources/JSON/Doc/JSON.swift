import yyjson
import Precondition
import CUtility

public final class JSON {

  @inlinable
  internal init(_ doc: UnsafeMutablePointer<yyjson_doc>) {
    self.docPointer = doc
  }

  @usableFromInline
  let docPointer: UnsafeMutablePointer<yyjson_doc>

  @inlinable
  deinit {
    yyjson_doc_free(docPointer)
  }
}

public extension JSON {

  @inlinable
  static func read(string: some ContiguousUTF8Bytes, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    return string.withContiguousUTF8Bytes { buffer in
      read(buffer: buffer, options: options, allocator: allocator)
    }
  }

  @inlinable
  static func read(buffer: UnsafeRawBufferPointer, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    precondition(!options.contains(.inSitu), "input buffer is immutable")
    return read(buffer: UnsafeMutableRawBufferPointer(mutating: buffer), options: options, allocator: allocator)
  }

  @inlinable
  static func read(buffer: UnsafeMutableRawBufferPointer, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    var err = yyjson_read_err()
    let doc = yyjson_read_opts(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue, allocator, &err)
    return doc.map(JSON.init).map(Result.success) ?? .failure(JSONReadError(err))
  }

  @inlinable
  static func read(path: UnsafePointer<CChar>, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    var err = yyjson_read_err()
    let doc = yyjson_read_file(path, options.rawValue, allocator, &err)
    return doc.map(JSON.init).map(Result.success) ?? .failure(JSONReadError(err))
  }

  @inlinable
  static func read(file: UnsafeMutablePointer<FILE>, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    var err = yyjson_read_err()
    let doc = yyjson_read_fp(file, options.rawValue, allocator, &err)
    return doc.map(JSON.init).map(Result.success) ?? .failure(JSONReadError(err))
  }
}

public extension JSON {
  @inlinable
  var readSize: Int {
    yyjson_doc_get_read_size(docPointer)
  }

  @inlinable
  var valueCount: Int {
    yyjson_doc_get_val_count(docPointer)
  }

  @inlinable
  var root: JSONValue? {
    yyjson_doc_get_root(docPointer).map { JSONValue($0, self) }
  }

  @inlinable
  static func maxMemoryUsage(bytesCount: Int, options: ReadOptions = .none) -> Int {
    yyjson_read_max_memory_usage(bytesCount, options.rawValue)
  }

}

extension JSON {
  public struct ReadOptions: OptionSet {
    public var rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }

    @_alwaysEmitIntoClient
    public static var none: Self { .init(rawValue: YYJSON_READ_NOFLAG) }
    @_alwaysEmitIntoClient
    public static var inSitu: Self { .init(rawValue: YYJSON_READ_INSITU) }
    @_alwaysEmitIntoClient
    public static var stopWhenDone: Self { .init(rawValue: YYJSON_READ_STOP_WHEN_DONE) }
    @_alwaysEmitIntoClient
    public static var allowTrailingCommas: Self { .init(rawValue: YYJSON_READ_ALLOW_TRAILING_COMMAS) }
    @_alwaysEmitIntoClient
    public static var allowComments: Self { .init(rawValue: YYJSON_READ_ALLOW_COMMENTS) }
    @_alwaysEmitIntoClient
    public static var allowInfAndNan: Self { .init(rawValue: YYJSON_READ_ALLOW_INF_AND_NAN) }
    @_alwaysEmitIntoClient
    public static var numberAsRaw: Self { .init(rawValue: YYJSON_READ_NUMBER_AS_RAW) }
    @_alwaysEmitIntoClient
    public static var bigNumberAsRaw: Self { .init(rawValue: YYJSON_READ_BIGNUM_AS_RAW) }
    @_alwaysEmitIntoClient
    public static var allowInvalidUnicode: Self { .init(rawValue: YYJSON_READ_ALLOW_INVALID_UNICODE) }
  }

  public struct WriteOptions: OptionSet {
    public var rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }

    @_alwaysEmitIntoClient
    public static var none: Self { .init(rawValue: YYJSON_WRITE_NOFLAG) }
    @_alwaysEmitIntoClient
    public static var pretty: Self { .init(rawValue: YYJSON_WRITE_PRETTY) }
    @_alwaysEmitIntoClient
    public static var prettyTwoSpaces: Self { .init(rawValue: YYJSON_WRITE_PRETTY_TWO_SPACES) }
    @_alwaysEmitIntoClient
    public static var escapeUnicode: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_UNICODE) }
    @_alwaysEmitIntoClient
    public static var escapeSlashes: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_SLASHES) }
    @_alwaysEmitIntoClient
    public static var allowInfAndNan: Self { .init(rawValue: YYJSON_WRITE_ALLOW_INF_AND_NAN) }
    @_alwaysEmitIntoClient
    public static var infAndNanAsNull: Self { .init(rawValue: YYJSON_WRITE_INF_AND_NAN_AS_NULL) }
    @_alwaysEmitIntoClient
    public static var allowInvalidUnicode: Self { .init(rawValue: YYJSON_WRITE_ALLOW_INVALID_UNICODE) }
    @_alwaysEmitIntoClient
    public static var newLineAtEnd: Self { .init(rawValue: YYJSON_WRITE_NEWLINE_AT_END) }

  }
}
