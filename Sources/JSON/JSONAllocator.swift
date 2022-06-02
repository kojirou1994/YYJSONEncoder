import yyjson
import Precondition

public struct JSONAllocator {
  @usableFromInline
  internal let alc: yyjson_alc

  public init(malloc: @escaping @convention(c) (UnsafeMutableRawPointer?, Int) -> UnsafeMutableRawPointer?, realloc: @escaping @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int) -> UnsafeMutableRawPointer?, free: @escaping @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void, context: UnsafeMutableRawPointer?) {
    alc = .init(malloc: malloc, realloc: realloc, free: free, ctx: context)
  }

  /// throws JSONError.bufferTooSmall
  /// - Parameter buffer: pre-allocated buffer
  public init(buffer: UnsafeMutableRawBufferPointer) throws {
    var alc = yyjson_alc()
    try preconditionOrThrow(
      yyjson_alc_pool_init(&alc, buffer.baseAddress, buffer.count),
      JSONError.bufferTooSmall
    )
    self.alc = alc
  }
}

public extension JSONAllocator {

  @inlinable
  var malloc: (UnsafeMutableRawPointer?, Int) -> UnsafeMutableRawPointer? {
    alc.malloc
  }

  @inlinable
  var realloc: (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int) -> UnsafeMutableRawPointer? {
    alc.realloc
  }

  @inlinable
  var free: (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void {
    alc.free
  }

  @inlinable
  var context: UnsafeMutableRawPointer? {
    alc.ctx
  }
}

@inlinable
func withOptionalAllocatorPointer<Result>(to value: JSONAllocator?, _ body: (_ allocator: UnsafePointer<yyjson_alc>?) throws -> Result) rethrows -> Result {
  if let value = value {
    return try withUnsafePointer(to: value.alc, body)
  }
  return try body(nil)
}
