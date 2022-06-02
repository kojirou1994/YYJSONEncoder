import yyjson

public enum JSONError: Error {
  case noMemory
  case bufferTooSmall
  case patchFail
}

public struct JSONReadError: Error {
  @inlinable
  internal init(_ err: yyjson_read_err) {
    self.err = err
    assert(code != .success)
  }

  @usableFromInline
  let err: yyjson_read_err
}

public extension JSONReadError {
  /// Error code
  var code: Code {
    .init(rawValue: err.code)
  }

  /// Short error message
  var message: UnsafePointer<CChar> {
    err.msg
  }

  /// Error byte position for input data (0 for success)
  var position: Int {
    err.pos
  }
}

extension JSONReadError {
  public struct Code: RawRepresentable {
    public var rawValue: yyjson_read_code

    @inlinable
    public init(rawValue: yyjson_read_code) {
      self.rawValue = rawValue
    }
  }
}

public extension JSONReadError.Code {
  @_alwaysEmitIntoClient
  static var success: Self { .init(rawValue: YYJSON_READ_SUCCESS) }
}

public struct JSONWriteError: Error {
  @inlinable
  internal init(_ err: yyjson_write_err) {
    self.err = err
    assert(code != .success)
  }

  @usableFromInline
  let err: yyjson_write_err
}

extension JSONWriteError: CustomStringConvertible {
  public var description: String {
    "JSONWriteError(code: \(code), message: \(String(cString: message))"
  }
}

public extension JSONWriteError {
  /// Error code
  var code: Code {
    .init(rawValue: err.code)
  }

  /// Short error message
  var message: UnsafePointer<CChar> {
    err.msg
  }

}

extension JSONWriteError {
  public struct Code: RawRepresentable {

    public var rawValue: yyjson_write_code

    @inlinable
    public init(rawValue: yyjson_write_code) {
      self.rawValue = rawValue
    }
  }
}

public extension JSONWriteError.Code {
  @_alwaysEmitIntoClient
  static var success: Self { .init(rawValue: YYJSON_WRITE_SUCCESS) }
}
