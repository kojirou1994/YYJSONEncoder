import JSON
import Precondition

public enum YYJSONDecodeError: Error, CustomStringConvertible, @unchecked Sendable {
  case yyjsonReadError(code: UInt32, message: String, position: Int)
  case numberOverflow(source: Any, target: Any.Type)
  case typeMismatch
  case keyNotFound(CodingKey, DecodingError.Context)

  public var description: String {
    switch self {
    case .yyjsonReadError(code: let code, message: let msg, position: let pos):
      return "Code: \(code), message: \(msg), position: \(pos)"
    case .numberOverflow(source: let source, target: let target):
      return "Can't convert number \(source) to \(target)"
    case .typeMismatch:
      return "Type mismatch"
    case let .keyNotFound(key, context):
      return "Key \(key) is not found in context: \(context)"
    }
  }
}

public struct YYJSONDecoder<T: JSONValueProtocol>: Decoder {

  public init(_ root: T) {
    self.root = root
    codingPath = .init()
    self.userInfo = .init()
  }

  internal init(root: T, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
    self.root = root
    self.codingPath = codingPath
    self.userInfo = userInfo
  }

  internal let root: T

  public let codingPath: [CodingKey]

  public let userInfo: [CodingUserInfoKey : Any]

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    precondition(root.isObject)
    return .init(_YYJSONKeyedDecodingContainer<T, Key>(obj: root.object!, codingPath: codingPath, userInfo: userInfo))
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    precondition(root.isArray)
    return _YYJSONUnkeyedDecodingContainer<T>(arr: root.array!, codingPath: codingPath, userInfo: userInfo)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    self
  }

}

struct _YYJSONKeyedDecodingContainer<T: JSONValueProtocol, Key: CodingKey>: KeyedDecodingContainerProtocol {

  let obj: T.Object
  let codingPath: [CodingKey]
  let userInfo: [CodingUserInfoKey : Any]

  var allKeys: [Key] {
    obj.compactMap { key in
      Key(stringValue: key.string!)
    }
  }

  func value(for key: Key) throws -> T {
    try obj[key.stringValue].unwrap(DecodingError.keyNotFound(key, .init(
      codingPath: self.codingPath,
      debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\").")))
  }

  func decoder(for key: Key) throws -> YYJSONDecoder<T> {
    try .init(root: value(for: key), codingPath: codingPath + CollectionOfOne(key as CodingKey), userInfo: userInfo)
  }

  func contains(_ key: Key) -> Bool {
    obj[key.stringValue] != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    try value(for: key).isNull
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    try decoder(for: key).decode(Bool.self)
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    try decoder(for: key).decode(String.self)
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    try decoder(for: key).decode(Double.self)
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    try decoder(for: key).decode(Float.self)
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    try decoder(for: key).decode(Int.self)
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    try decoder(for: key).decode(Int8.self)
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    try decoder(for: key).decode(Int16.self)
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    try decoder(for: key).decode(Int32.self)
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    try decoder(for: key).decode(Int64.self)
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    try decoder(for: key).decode(UInt.self)
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    try decoder(for: key).decode(UInt8.self)
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    try decoder(for: key).decode(UInt16.self)
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    try decoder(for: key).decode(UInt32.self)
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    try decoder(for: key).decode(UInt64.self)
  }

  func decode<R>(_ type: R.Type, forKey key: Key) throws -> R where R : Decodable {
    try decoder(for: key).decode(R.self)
  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    try decoder(for: key).container(keyedBy: type)
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    try decoder(for: key).unkeyedContainer()
  }

  func superDecoder() throws -> Decoder {
    fatalError()
  }

  func superDecoder(forKey key: Key) throws -> Decoder {
    fatalError()
  }

}

struct _YYJSONUnkeyedDecodingContainer<T: JSONValueProtocol>: UnkeyedDecodingContainer {

  let arr: T.Array
  let codingPath: [CodingKey]
  let userInfo: [CodingUserInfoKey : Any]

  var currentIndex: T.Array.Index

  init(arr: T.Array,
       codingPath: [CodingKey],
       userInfo: [CodingUserInfoKey : Any]
  ) {
    self.arr = arr
    self.codingPath = codingPath
    self.userInfo = userInfo
    self.currentIndex = arr.startIndex
  }

  var count: Int? {
    arr.count
  }

  var isAtEnd: Bool {
    currentIndex == arr.endIndex
  }

  mutating func nextElement() throws -> T {
    guard !isAtEnd else {
//      throw DecodingError.valueNotFound(
//        T.self,
//        .init(codingPath: path,
//              debugDescription: message,
//              underlyingError: nil))
      fatalError()
    }
    let value = arr[currentIndex]
    currentIndex = arr.index(after: currentIndex)
    return value
  }

  mutating func nextElementDecoder() throws -> YYJSONDecoder<T> {
    try .init(root: nextElement(), codingPath: codingPath, userInfo: userInfo)
  }

  mutating func decodeNil() throws -> Bool {
    try nextElement().isNull
  }

  mutating func decode(_ type: Bool.Type) throws -> Bool {
    try nextElementDecoder().decode(Bool.self)
  }

  mutating func decode(_ type: String.Type) throws -> String {
    try nextElementDecoder().decode(String.self)
  }

  mutating func decode(_ type: Double.Type) throws -> Double {
    try nextElementDecoder().decode(Double.self)
  }

  mutating func decode(_ type: Float.Type) throws -> Float {
    try nextElementDecoder().decode(Float.self)
  }

  mutating func decode(_ type: Int.Type) throws -> Int {
    try nextElementDecoder().decode(Int.self)
  }

  mutating func decode(_ type: Int8.Type) throws -> Int8 {
    try nextElementDecoder().decode(Int8.self)
  }

  mutating func decode(_ type: Int16.Type) throws -> Int16 {
    try nextElementDecoder().decode(Int16.self)
  }

  mutating func decode(_ type: Int32.Type) throws -> Int32 {
    try nextElementDecoder().decode(Int32.self)
  }

  mutating func decode(_ type: Int64.Type) throws -> Int64 {
    try nextElementDecoder().decode(Int64.self)
  }

  mutating func decode(_ type: UInt.Type) throws -> UInt {
    try nextElementDecoder().decode(UInt.self)
  }

  mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
    try nextElementDecoder().decode(UInt8.self)
  }

  mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
    try nextElementDecoder().decode(UInt16.self)
  }

  mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
    try nextElementDecoder().decode(UInt32.self)
  }

  mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
    try nextElementDecoder().decode(UInt64.self)
  }

  mutating func decode<R>(_ type: R.Type) throws -> R where R : Decodable {
    try nextElementDecoder().decode(R.self)
  }

  mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    try nextElementDecoder().container(keyedBy: type)
  }

  mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    try nextElementDecoder().unkeyedContainer()
  }

  mutating func superDecoder() throws -> Decoder {
    fatalError()
  }

}

extension YYJSONDecoder: SingleValueDecodingContainer {

  public func decodeNil() -> Bool {
    root.isNull
  }

  public func decode(_ type: Bool.Type) throws -> Bool {
    try root.bool.unwrap()
  }

  public func decode(_ type: String.Type) throws -> String {
    try root.string.unwrap()
  }

  public func decode(_ type: Double.Type) throws -> Double {
    try preconditionOrThrow(root.isNumber)
    if let v = root.int64 {
      return Double(v)
    } else if let v = root.uint64 {
      return Double(v)
    } else {
      return root.unsafeDouble
    }
  }

  public func decode(_ type: Float.Type) throws -> Float {
    let double = try decode(Double.self)
    return try Float(exactly: double).unwrap(YYJSONDecodeError.numberOverflow(source: double, target: Float.self))
  }

  public func decode(_ type: Int.Type) throws -> Int {
    try root.convertInteger()
  }

  public func decode(_ type: Int8.Type) throws -> Int8 {
    try root.convertInteger()
  }

  public func decode(_ type: Int16.Type) throws -> Int16 {
    try root.convertInteger()
  }

  public func decode(_ type: Int32.Type) throws -> Int32 {
    try root.convertInteger()
  }

  public func decode(_ type: Int64.Type) throws -> Int64 {
    try root.convertInteger()
  }

  public func decode(_ type: UInt.Type) throws -> UInt {
    try root.convertInteger()
  }

  public func decode(_ type: UInt8.Type) throws -> UInt8 {
    try root.convertInteger()
  }

  public func decode(_ type: UInt16.Type) throws -> UInt16 {
    try root.convertInteger()
  }

  public func decode(_ type: UInt32.Type) throws -> UInt32 {
    try root.convertInteger()
  }

  public func decode(_ type: UInt64.Type) throws -> UInt64 {
    try root.convertInteger()
  }

  public func decode<R>(_ type: R.Type) throws -> R where R : Decodable {
    try .init(from: self)
  }

}

// MARK: Number convertion
extension JSONValueProtocol {

  func convertInteger<Output: FixedWidthInteger>() throws -> Output {

    func convert<Input: FixedWidthInteger, O: FixedWidthInteger>(_ input: Input) throws -> O {
      guard let number = O(exactly: input) else {
        throw YYJSONDecodeError.numberOverflow(source: input, target: Output.self)
      }
      return number
    }

    if let value = int64 {
      return try convert(value)
    } else if let value = uint64 {
      return try convert(value)
    } else {
      throw YYJSONDecodeError.typeMismatch
    }
  }

}
