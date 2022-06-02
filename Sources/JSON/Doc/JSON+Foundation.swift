import Foundation

public extension JSON {

  @inlinable
  static func read<T>(bytes: T, options: ReadOptions = .none, allocator: JSONAllocator? = nil) throws -> JSON where T: ContiguousBytes {
    try bytes.withUnsafeBytes { try .read(buffer: $0, options: options, allocator: allocator) }
  }
}
