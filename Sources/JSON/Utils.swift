extension StringProtocol {
  @inlinable
  func withCStringBuffer<R>(_ body: (UnsafeBufferPointer<CChar>) throws -> R) rethrows -> R {
    try withContiguousStorageIfAvailable { try $0.withMemoryRebound(to: CChar.self, body) }
    ?? ContiguousArray(utf8).withUnsafeBufferPointer { try $0.withMemoryRebound(to: CChar.self, body) }
  }
}
