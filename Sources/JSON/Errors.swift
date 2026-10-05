import yyjson
import CUtility

public struct JSONReadError: Error, @unchecked Sendable {
  @export(implementation)
  internal init(_ err: yyjson_read_err) {
    self.err = err
    assert(code != .success)
  }

  @usableFromInline
  let err: yyjson_read_err
}

public extension JSONReadError {
  /// Error code
  @export(implementation)
  var code: Code {
    .init(rawValue: err.code)
  }

  /// Short error message
  @export(implementation)
  var message: StaticCString {
    .init(cString: err.msg)
  }

  /// Error byte position for input data (0 for success)
  @export(implementation)
  var position: Int {
    err.pos
  }
}

extension JSONReadError {
  public struct Code: RawRepresentable {
    public let rawValue: UInt32

    @export(implementation)
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
}

extension JSONReadError: CustomStringConvertible {
  public var description: String {
    "JSONReadError(code: \(code), message: \(message.string)"
  }
}

public extension JSONReadError.Code {
  @export(implementation)
  static var success: Self { .init(rawValue: YYJSON_READ_SUCCESS) }
}

public struct JSONWriteError: Error, @unchecked Sendable {
  @export(implementation)
  internal init(_ err: yyjson_write_err) {
    self.err = err
    assert(code != .success)
  }

  @usableFromInline
  let err: yyjson_write_err
}

extension JSONWriteError: CustomStringConvertible {
  public var description: String {
    "JSONWriteError(code: \(code), message: \(message.string)"
  }
}

public extension JSONWriteError {
  /// Error code
  @export(implementation)
  var code: Code {
    .init(rawValue: err.code)
  }

  /// Short error message
  @export(implementation)
  var message: StaticCString {
    .init(cString: err.msg)
  }

}

extension JSONWriteError {
  public struct Code: RawRepresentable {

    public let rawValue: yyjson_write_code

    @export(implementation)
    public init(rawValue: yyjson_write_code) {
      self.rawValue = rawValue
    }
  }
}

public extension JSONWriteError.Code {
  @export(implementation)
  static var success: Self { .init(rawValue: YYJSON_WRITE_SUCCESS) }
}

public struct JSONPointerError: Error, @unchecked Sendable {
  @export(implementation)
  internal init(_ err: yyjson_ptr_err) {
    self.err = err
    assert(code != .none)
  }

  @usableFromInline
  let err: yyjson_ptr_err
}

public extension JSONPointerError {
  /// Error code
  @export(implementation)
  var code: Code {
    .init(rawValue: err.code)
  }

  /// Short error message
  @export(implementation)
  var message: StaticCString {
    .init(cString: err.msg)
  }

  /// Error byte position for input data (0 for success)
  @export(implementation)
  var position: Int {
    err.pos
  }
}

extension JSONPointerError {
  public struct Code: RawRepresentable {
    public var rawValue: yyjson_ptr_code

    @export(implementation)
    public init(rawValue: yyjson_ptr_code) {
      self.rawValue = rawValue
    }
  }
}

public extension JSONPointerError.Code {
  @export(implementation)
  static var none: Self { .init(rawValue: YYJSON_PTR_ERR_NONE) }
}
