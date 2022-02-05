import yyjson
import Precondition

public final class JSON {
  @usableFromInline
  internal init(_ buffer: UnsafeRawBufferPointer, options: ReadOptions, allocator: JSONAllocator?) throws {
    var err = yyjson_read_err()
    let doc = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_read_opts(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue, allocator, &err)
    }
    self.doc = try doc.unwrap(JSONReadError(err))
  }

  @usableFromInline
  internal init(path: UnsafePointer<CChar>, options: ReadOptions, allocator: JSONAllocator?) throws {
    var err = yyjson_read_err()
    let doc = withOptionalAllocatorPointer(to: allocator) { allocator in
      yyjson_read_file(path, options.rawValue, allocator, &err)
    }
    self.doc = try doc.unwrap(JSONReadError(err))
  }

  @usableFromInline
  let doc: UnsafeMutablePointer<yyjson_doc>

  deinit {
    yyjson_doc_free(doc)
  }
}

public extension JSON {

  @inlinable
  static func read<T: StringProtocol>(string: T, options: ReadOptions = .none, allocator: JSONAllocator? = nil) throws -> JSON {
    try string.utf8.withContiguousBuffer { buffer in
      try .init(.init(buffer), options: options, allocator: allocator)
    }
  }

  @inlinable
  static func read(path: String, options: ReadOptions = .none, allocator: JSONAllocator? = nil) throws -> JSON {
    try .init(path: path, options: options, allocator: allocator)
  }
}

public extension JSON {
  @inlinable
  var readSize: Int {
    yyjson_doc_get_read_size(doc)
  }

  @inlinable
  var valueCount: Int {
    yyjson_doc_get_val_count(doc)
  }

  @inlinable
  var root: JSONValue {
    .init(val: yyjson_doc_get_root(doc), doc: self)
  }

}

extension JSON {
  public struct ReadOptions: OptionSet {
    public var rawValue: UInt32

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
  }

  public struct WriteOptions: OptionSet {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
    @_alwaysEmitIntoClient
    public static var none: Self { .init(rawValue: YYJSON_WRITE_NOFLAG) }
    @_alwaysEmitIntoClient
    public static var pretty: Self { .init(rawValue: YYJSON_WRITE_PRETTY) }
    @_alwaysEmitIntoClient
    public static var escapeUnicode: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_UNICODE) }
    @_alwaysEmitIntoClient
    public static var escapeSlashes: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_SLASHES) }
    @_alwaysEmitIntoClient
    public static var allowInfAndNan: Self { .init(rawValue: YYJSON_WRITE_ALLOW_INF_AND_NAN) }

  }
}
