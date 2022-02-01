import yyjson
import Foundation

public final class JSON {
  @usableFromInline
  internal init(_ doc: UnsafeMutablePointer<yyjson_doc>) {
    self.doc = doc
  }

  @usableFromInline
  let doc: UnsafeMutablePointer<yyjson_doc>

  deinit {
    yyjson_doc_free(doc)
  }
}

public extension JSON {

  @inlinable
  static func read(buffer: Data, options: ReadOptions = .none) throws -> JSON {
    buffer.withUnsafeBytes { buffer in
        .init(yyjson_read(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue))
    }!
  }

  static func read<T>(buffer: T, options: ReadOptions = .none) throws -> JSON where T: Collection, T.Element == UInt8 {
    buffer.withContiguousStorageIfAvailable { buffer in
        .init(yyjson_read(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue))
    }!
  }

  static func read(string: String, options: ReadOptions = .none) throws -> JSON {
    var copy = string
    return copy.withUTF8 { buffer in
        .init(yyjson_read(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue))
    }
  }

  static func read(path: String, options: ReadOptions = .none) throws -> JSON {
    .init(yyjson_read_file(path, options.rawValue, nil, nil))
  }
}

public extension JSON {
  var readSize: Int {
    yyjson_doc_get_read_size(doc)
  }

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
