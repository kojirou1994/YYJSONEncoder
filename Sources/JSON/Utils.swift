extension StringProtocol {
  @inlinable
  func withCStringBuffer<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
    try utf8.withContiguousStorageIfAvailable { try body(UnsafeRawBufferPointer($0)) }
    ?? ContiguousArray(utf8).withUnsafeBytes(body)
  }
}
