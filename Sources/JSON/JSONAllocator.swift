import yyjson
import Precondition

public typealias JSONAllocator = yyjson_alc

extension JSONAllocator {

  /// throws JSONError.bufferTooSmall
  /// - Parameter buffer: pre-allocated buffer
  public init(buffer: UnsafeMutableRawBufferPointer) throws {
    self.init()
    try preconditionOrThrow(
      yyjson_alc_pool_init(&self, buffer.baseAddress, buffer.count),
      JSONError.bufferTooSmall
    )
  }
}

@inlinable
func withOptionalAllocatorPointer<Result>(to alc: JSONAllocator?, _ body: (_ allocator: UnsafePointer<yyjson_alc>?) throws -> Result) rethrows -> Result {
  if let alc = alc {
    return try withUnsafePointer(to: alc, body)
  }
  return try body(nil)
}
