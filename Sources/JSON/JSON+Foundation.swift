import Foundation

public extension JSON {

  @inlinable
  static func read<T>(_ buffer: T, options: ReadOptions = .none, allocator: JSONAllocator? = nil) throws -> JSON where T: ContiguousBytes {
    try buffer.withUnsafeBytes { try .init($0, options: options, allocator: allocator) }
  }
}
