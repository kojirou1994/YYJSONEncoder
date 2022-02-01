extension Collection {
  @usableFromInline
  func withContiguousBuffer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
    try withContiguousStorageIfAvailable(body) ?? ContiguousArray(self).withUnsafeBufferPointer(body)
  }
}
