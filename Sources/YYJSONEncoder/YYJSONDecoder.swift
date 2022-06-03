import yyjson
import Foundation
import JSON

public enum YYJSONDecodeError: Error, CustomStringConvertible {
  case yyjsonReadError(code: UInt32, message: String, position: Int)
  case numberOverflow(source: Any, target: Any.Type)
  case typeMismatch
  case keyNotFound(CodingKey, DecodingError.Context)

  internal static func yyjsonReadError(_ error: yyjson_read_err) -> Self {
    .yyjsonReadError(code: error.code, message: error.msg.map(String.init(cString:)) ?? "", position: error.pos)
  }

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

public struct YYJSONDecoder: Decoder {

  public init(_ root: JSONValue) {
    self.root = root
    codingPath = .init()
    self.userInfo = .init()
  }

  internal init(root: JSONValue, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
    self.root = root
    self.codingPath = codingPath
    self.userInfo = userInfo
  }

  internal let root: JSONValue

  public let codingPath: [CodingKey]

  public let userInfo: [CodingUserInfoKey : Any]

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    precondition(root.isObject)
    return .init(_YYJSONKeyedDecodingContainer<Key>(decoder: self))
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    precondition(root.isArray)
    return _YYJSONUnkeyedDecodingContainer(decoder: self, codingPath: codingPath)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    self
  }

}

struct _YYJSONKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

  let decoder: YYJSONDecoder
  let obj: JSONValue.Object

  init(decoder: YYJSONDecoder) {
    self.decoder = decoder
    obj = decoder.root.object!
  }

  var codingPath: [CodingKey] {
    decoder.codingPath
  }

  var allKeys: [Key] {
    obj.compactMap { kv in
      Key(stringValue: kv.key.string!)
    }
  }

  func value(for key: Key) throws -> JSONValue {
    try obj[key.stringValue].unwrap(DecodingError.keyNotFound(key, .init(
      codingPath: self.codingPath,
      debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\").")))
  }

  func decoder(for key: Key) throws -> YYJSONDecoder {
    try .init(root: value(for: key), codingPath: codingPath + CollectionOfOne(key as CodingKey), userInfo: decoder.userInfo)
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

  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    try decoder(for: key).decode(T.self)
  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    try decoder(for: key).container(keyedBy: type)
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    try decoder(for: key).unkeyedContainer()
  }

  func superDecoder() throws -> Decoder {
    decoder
  }

  func superDecoder(forKey key: Key) throws -> Decoder {
    decoder
  }

}

struct _YYJSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {

  let decoder: YYJSONDecoder

  let arr: JSONValue.Array
  var currentIndex: JSONValue.Array.Index

  var codingPath: [CodingKey]

  init(decoder: YYJSONDecoder,
       codingPath: [CodingKey]) {
    self.decoder = decoder
    self.codingPath = codingPath
    self.arr = decoder.root.array!
    self.currentIndex = arr.startIndex
  }

  var count: Int? {
    arr.count
  }

  var isAtEnd: Bool {
    currentIndex == arr.endIndex
  }

  mutating func nextElement() throws -> JSONValue {
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

  mutating func nextElementDecoder() throws -> YYJSONDecoder {
    try .init(root: nextElement(), codingPath: codingPath, userInfo: decoder.userInfo)
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

  mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
    try nextElementDecoder().decode(T.self)
  }

  mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    try nextElementDecoder().container(keyedBy: type)
  }

  mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    try nextElementDecoder().unkeyedContainer()
  }

  mutating func superDecoder() throws -> Decoder {
    decoder
  }


}

import Precondition

extension YYJSONDecoder: SingleValueDecodingContainer {

  public func decodeNil() -> Bool {
    root.isNull
  }

  public func decode(_ type: Bool.Type) throws -> Bool {
    try root.bool.unwrap(YYJSONDecodeError.typeMismatch)
  }

  public func decode(_ type: String.Type) throws -> String {
    try root.string.unwrap(YYJSONDecodeError.typeMismatch)
  }

  public func decode(_ type: Double.Type) throws -> Double {
    try root.double.unwrap(YYJSONDecodeError.typeMismatch)
  }

  public func decode(_ type: Float.Type) throws -> Float {
    let double = try decode(Double.self)
    if abs(double) <= Double(Float.greatestFiniteMagnitude) {
      throw YYJSONDecodeError.numberOverflow(source: double, target: Float.self)
    }
    return Float(double)
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

  public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
    try .init(from: self)
  }

}

// MARK: Number convertion
extension JSONValueProtocol {

  func convertInteger<Output: FixedWidthInteger>() throws -> Output {

    func convert<Input: FixedWidthInteger, Output: FixedWidthInteger>(_ input: Input) throws -> Output {
      guard let number = Output(exactly: input) else {
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
