import protocol Foundation.ContiguousBytes

public extension JSON {

  @inlinable
  static func read(bytes: some ContiguousBytes, options: ReadOptions = .none, allocator: UnsafePointer<JSONAllocator>? = nil) -> Result<JSON, JSONReadError> {
    bytes.withUnsafeBytes { read(buffer: $0, options: options, allocator: allocator) }
  }
}
