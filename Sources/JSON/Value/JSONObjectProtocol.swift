public protocol JSONObjectProtocol {
  associatedtype Value

  subscript(keyBuffer: UnsafeRawBufferPointer) -> Value? { get }
}

public extension JSONObjectProtocol {
  @inlinable
  subscript<T: StringProtocol>(key: T) -> Value? {
    key.withCStringBuffer { keyBuffer in
      self[keyBuffer]
    }
  }
}
