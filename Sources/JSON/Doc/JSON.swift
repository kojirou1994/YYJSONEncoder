import yyjson
import Precondition
import CUtility

public struct JSON: ~Copyable {

  @inlinable
  internal init(_ doc: UnsafeMutablePointer<yyjson_doc>) {
    self.rawAddress = doc
  }

  @usableFromInline
  let rawAddress: UnsafeMutablePointer<yyjson_doc>

  @inlinable
  deinit {
    yyjson_doc_free(rawAddress)
  }
}

public extension JSON {

  @inlinable
  static func read(string: some ContiguousUTF8Bytes, options: ReadOptions = .none) throws(JSONReadError) -> JSON {
    try string.withContiguousUTF8Bytes { buffer throws(JSONReadError) in
      try read(buffer: buffer, options: options)
    }
  }

  @inlinable
  static func read(buffer: UnsafeRawBufferPointer, options: ReadOptions = .none) throws(JSONReadError) -> JSON {
    precondition(!options.contains(.inSitu), "input buffer is immutable")
    return try read(buffer: UnsafeMutableRawBufferPointer(mutating: buffer), options: options)
  }

  @inlinable
  static func read(buffer: UnsafeMutableRawBufferPointer, options: ReadOptions = .none)  throws(JSONReadError) -> JSON {
    var err = yyjson_read_err()
    if let doc = yyjson_read_opts(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue, nil, &err) {
      return .init(doc)
    }
    throw JSONReadError(err)
  }

  @inlinable
  static func read(path: UnsafePointer<CChar>, options: ReadOptions = .none)  throws(JSONReadError) -> JSON {
    var err = yyjson_read_err()
    if let doc = yyjson_read_file(path, options.rawValue, nil, &err) {
      return .init(doc)
    }
    throw JSONReadError(err)
  }

  @inlinable
  static func read(file: UnsafeMutablePointer<FILE>, options: ReadOptions = .none)  throws(JSONReadError) -> JSON {
    var err = yyjson_read_err()
    if let doc = yyjson_read_fp(file, options.rawValue, nil, &err) {
      return .init(doc)
    }
    throw JSONReadError(err)
  }
}

public extension JSON {
  @inlinable
  var readSize: Int {
    yyjson_doc_get_read_size(rawAddress)
  }

  @inlinable
  var valueCount: Int {
    yyjson_doc_get_val_count(rawAddress)
  }

  @inlinable
  var root: JSONValue {
    @_lifetime(borrow self)
    get {
      _overrideLifetime(.init(yyjson_doc_get_root(rawAddress)), borrowing: self)
    }
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
    @_alwaysEmitIntoClient
    public static var allowBOM: Self { .init(rawValue: YYJSON_READ_ALLOW_BOM) }
    @_alwaysEmitIntoClient
    public static var allowExtendedNumber: Self { .init(rawValue: YYJSON_READ_ALLOW_EXT_NUMBER) }
    @_alwaysEmitIntoClient
    public static var allowExtendedEscape: Self { .init(rawValue: YYJSON_READ_ALLOW_EXT_ESCAPE) }
    @_alwaysEmitIntoClient
    public static var allowExtendedWhitespace: Self { .init(rawValue: YYJSON_READ_ALLOW_EXT_WHITESPACE) }
    @_alwaysEmitIntoClient
    public static var allowSingleQuotedString: Self { .init(rawValue: YYJSON_READ_ALLOW_SINGLE_QUOTED_STR) }
    @_alwaysEmitIntoClient
    public static var allowUnquotedKey: Self { .init(rawValue: YYJSON_READ_ALLOW_UNQUOTED_KEY) }
    @_alwaysEmitIntoClient
    public static var allowJSON5: Self { .init(rawValue: YYJSON_READ_JSON5) }
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
    @_alwaysEmitIntoClient
    public static var lowercaseHex: Self { .init(rawValue: YYJSON_WRITE_LOWERCASE_HEX) }


    @_alwaysEmitIntoClient
    public static var fpToFloat: Self { .init(rawValue: 1 << (32 - 5)) }

    @_alwaysEmitIntoClient
    public static func fpToFixed(_ v: UInt32) -> Self { .init(rawValue: v << (32 - 4)) }

  }
}
