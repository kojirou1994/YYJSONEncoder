import protocol Foundation.ContiguousBytes

public extension JSON {

  @inlinable
  static func read<T>(bytes: T, options: ReadOptions = .none, allocator: JSONAllocator? = nil) -> Result<JSON, JSONReadError> where T: ContiguousBytes {
    bytes.withUnsafeBytes { read(buffer: $0, options: options, allocator: allocator) }
  }
}
