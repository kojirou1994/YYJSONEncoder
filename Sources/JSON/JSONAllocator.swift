import yyjson
import Precondition

public typealias JSONAllocator = yyjson_alc

extension JSONAllocator {

  /// fail if buffer is invalid
  /// - Parameter buffer: pre-allocated buffer
  public init?(buffer: UnsafeMutableRawBufferPointer) {
    self.init()
    assert(!buffer.isEmpty)
    if !yyjson_alc_pool_init(&self, buffer.baseAddress, buffer.count) {
      return nil
    }
  }
}

@inlinable
func withOptionalAllocatorPointer<Result>(to alc: JSONAllocator?, _ body: (_ allocator: UnsafePointer<yyjson_alc>?) throws -> Result) rethrows -> Result {
  if let alc = alc {
    return try withUnsafePointer(to: alc, body)
  }
  return try body(nil)
}
