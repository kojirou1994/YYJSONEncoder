import yyjson
import Precondition

public typealias JSONAllocator = yyjson_alc

extension JSONAllocator {

  /// fail if buffer is invalid
  /// - Parameter buffer: pre-allocated buffer
  public mutating func use(buffer: UnsafeMutableRawBufferPointer) -> Bool {
    assert(!buffer.isEmpty)
    return yyjson_alc_pool_init(&self, buffer.baseAddress, buffer.count)
  }
}

public struct JSONDynamicAllocator: ~Copyable {

  @usableFromInline
  let allocator: UnsafeMutablePointer<yyjson_alc>

  @inlinable
  public init() throws {
    allocator = try yyjson_alc_dyn_new().unwrap("no memory")
  }

  @inlinable
  deinit {
    yyjson_alc_dyn_free(allocator)
  }

  @inlinable
  public func withUnsafeAllocatorPointer<Result>(_ body: (_ allocator: UnsafePointer<JSONAllocator>?) throws -> Result) rethrows -> Result {
    try body(allocator)
  }
}
