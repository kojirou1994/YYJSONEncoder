import yyjson

public final class JSON {
  internal init(_ doc: UnsafeMutablePointer<yyjson_doc>) {
    self.doc = doc
  }

  let doc: UnsafeMutablePointer<yyjson_doc>

  deinit {
    yyjson_doc_free(doc)
  }
}

public extension JSON {
  static func read(string: String, options: ReadOptions = .none) throws -> JSON {
    var copy = string
    return copy.withUTF8 { buffer in
        .init(yyjson_read(.init(OpaquePointer(buffer.baseAddress)), buffer.count, options.rawValue))
    }
  }
}

public extension JSON {
  var readSize: Int {
    yyjson_doc_get_read_size(doc)
  }

  var valueCount: Int {
    yyjson_doc_get_val_count(doc)
  }

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

    public static var none: Self { .init(rawValue: YYJSON_READ_NOFLAG) }
    public static var inSitu: Self { .init(rawValue: YYJSON_READ_INSITU) }
    public static var stopWhenDone: Self { .init(rawValue: YYJSON_READ_STOP_WHEN_DONE) }
    public static var allowTrailingCommas: Self { .init(rawValue: YYJSON_READ_ALLOW_TRAILING_COMMAS) }
    public static var allowComments: Self { .init(rawValue: YYJSON_READ_ALLOW_COMMENTS) }
    public static var allowInfAndNan: Self { .init(rawValue: YYJSON_READ_ALLOW_INF_AND_NAN) }
  }

  public struct WriteOptions: OptionSet {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
    public static var none: Self { .init(rawValue: YYJSON_WRITE_NOFLAG) }
    public static var pretty: Self { .init(rawValue: YYJSON_WRITE_PRETTY) }
    public static var escapeUnicode: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_UNICODE) }
    public static var escapeSlashes: Self { .init(rawValue: YYJSON_WRITE_ESCAPE_SLASHES) }
    public static var allowInfAndNan: Self { .init(rawValue: YYJSON_WRITE_ALLOW_INF_AND_NAN) }

  }
}
