import yyjson
import Precondition

public struct JSONAllocator: ~Copyable {

  @usableFromInline
  internal let rawAddress: UnsafeMutablePointer<yyjson_alc>?

  @usableFromInline
  internal let isDynamic: Bool

  @inlinable
  init(rawAddress: UnsafeMutablePointer<yyjson_alc>?, isDynamic: Bool) {
    self.rawAddress = rawAddress
    self.isDynamic = isDynamic
  }

  @inlinable
  deinit {
    if isDynamic {
      yyjson_alc_dyn_free(rawAddress)
    }
  }
}

public extension JSONAllocator {

  @inlinable
  static var `default`: Self {
    .init(rawAddress: nil, isDynamic: false)
  }

  @inlinable
  static func dynamic() throws -> Self {
    .init(rawAddress: try yyjson_alc_dyn_new().unwrap("no memory"), isDynamic: true)
  }

  @inlinable
  static func withCustom(
    malloc: (@convention(c) (UnsafeMutableRawPointer?, Int) -> UnsafeMutableRawPointer?)!,
    realloc: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int, Int) -> UnsafeMutableRawPointer?)!,
    free: (@convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void)!,
    ctx: UnsafeMutableRawPointer!,
    _ body: (borrowing JSONAllocator) -> Void,
  ) {
    var alc = yyjson_alc(malloc: malloc, realloc: realloc, free: free, ctx: ctx)
    withUnsafeMutablePointer(to: &alc) { ptr in
      let alcc = Self(rawAddress: ptr, isDynamic: false)
      body(alcc)
    }
  }

  /// fail if buffer is invalid
  /// - Parameter buffer: pre-allocated buffer
  @inlinable
  static func withPool(
    buffer: UnsafeMutableRawBufferPointer,
    _ body: (borrowing JSONAllocator) -> Void,
  ) {
    assert(!buffer.isEmpty)
    var alc = yyjson_alc(malloc: nil, realloc: nil, free: nil, ctx: nil)
    precondition(yyjson_alc_pool_init(&alc, buffer.baseAddress, buffer.count))
    withUnsafeMutablePointer(to: &alc) { ptr in
      let alcc = Self(rawAddress: ptr, isDynamic: false)
      body(alcc)
    }
  }

}
