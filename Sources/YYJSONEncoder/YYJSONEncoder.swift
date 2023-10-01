import JSON
import Precondition

public struct YYJSONEncoder {

  public init() {
  }

  public func encode<T>(_ value: T) throws -> MutableJSON where T : Encodable {
    let encoder = try _YYJSONEncoder(doc:  MutableJSON().unwrap(), codingPath: .init(), userInfo: .init())
    try value.encode(to: encoder)
    assert(encoder.doc.root == nil)
    encoder.doc.root = encoder.result
    return encoder.doc
  }

}

final class _YYJSONEncoder: Encoder {

  let doc: MutableJSON
  let codingPath: [CodingKey]
  let userInfo: [CodingUserInfoKey: Any]

  var result: MutableJSONValue?

  init(doc: MutableJSON, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
    self.doc = doc
    self.codingPath = codingPath
    self.userInfo = userInfo
  }

  func checkResultIsNull() {
    assert(result == nil, "The result is not null, this call will overwrite it")
  }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    checkResultIsNull()

    let object = try! doc.createObject().unwrap()
    result = object

    return .init(_YYJSONKeyedEncodingContainerProtocol(object: object.object!, codingPath: codingPath))
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    checkResultIsNull()
    let array = try! doc.createArray().unwrap()
    result = array

    return _YYJSONUnkeyedEncodingContainer(array: array.array!, codingPath: codingPath)
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    checkResultIsNull()

    return self
  }
}

extension _YYJSONEncoder: SingleValueEncodingContainer {
  func encodeNil() throws {
    result = try doc.createNull().unwrap()
  }

  func encode(_ value: Bool) throws {
    result = try doc.create(value).unwrap()
  }

  func encode(_ value: String) throws {
    result = try doc.create(string: value).unwrap()
  }

  func encode(_ value: Double) throws {
    result = try doc.create(value).unwrap()
  }

  func encode(_ value: Float) throws {
    result = try doc.create(Double(value)).unwrap()
  }

  func encode(_ value: Int) throws {
    result = try doc.create(Int64(value)).unwrap()
  }

  func encode(_ value: Int8) throws {
    result = try doc.create(Int64(value)).unwrap()
  }

  func encode(_ value: Int16) throws {
    result = try doc.create(Int64(value)).unwrap()
  }

  func encode(_ value: Int32) throws {
    result = try doc.create(Int64(value)).unwrap()
  }

  func encode(_ value: Int64) throws {
    result = try doc.create(value).unwrap()
  }

  func encode(_ value: UInt) throws {
    result = try doc.create(UInt64(value)).unwrap()
  }

  func encode(_ value: UInt8) throws {
    result = try doc.create(UInt64(value)).unwrap()
  }

  func encode(_ value: UInt16) throws {
    result = try doc.create(UInt64(value)).unwrap()
  }

  func encode(_ value: UInt32) throws {
    result = try doc.create(UInt64(value)).unwrap()
  }

  func encode(_ value: UInt64) throws {
    result = try doc.create(UInt64(value)).unwrap()
  }

  func encode<T>(_ value: T) throws where T : Encodable {
    try value.encode(to: self)
  }

}

struct _YYJSONUnkeyedEncodingContainer: UnkeyedEncodingContainer {

  let array: MutableJSONValue.Array
  let codingPath: [CodingKey]

  mutating func encode(_ value: String) throws {
    array.append(try array.rawValue.document.create(string: value).unwrap())
  }

  mutating func encode(_ value: Double) throws {
    array.append(try array.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Float) throws {
    array.append(try array.rawValue.document.create(Double(value)).unwrap())
  }

  mutating func encode(_ value: Int) throws {
    array.append(try array.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int8) throws {
    array.append(try array.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int16) throws {
    array.append(try array.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int32) throws {
    array.append(try array.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int64) throws {
    array.append(try array.rawValue.document.create(value).unwrap())
  }

  mutating func encode(_ value: UInt) throws {
    array.append(try array.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt8) throws {
    array.append(try array.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt16) throws {
    array.append(try array.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt32) throws {
    array.append(try array.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt64) throws {
    array.append(try array.rawValue.document.create(value).unwrap())
  }

  mutating func encode<T>(_ value: T) throws where T : Encodable {
    let encoder = _YYJSONEncoder(doc: array.rawValue.document, codingPath: codingPath, userInfo: .init())
    try value.encode(to: encoder)
    if let result = encoder.result {
      array.append(result)
    }
  }

  mutating func encode(_ value: Bool) throws {
    array.append(try array.rawValue.document.create(value).unwrap())
  }

  var count: Int {
    array.count
  }

  mutating func encodeNil() throws {
    array.append(try array.rawValue.document.createNull().unwrap())
  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    let object = try! array.rawValue.document.createObject().unwrap()

    return .init(_YYJSONKeyedEncodingContainerProtocol(object: object.object!, codingPath: codingPath))
  }

  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    let nested = try! array.rawValue.document.createArray().unwrap()
    array.append(nested)
    return Self.init(array: nested.array!, codingPath: codingPath)
  }

  mutating func superEncoder() -> Encoder {
    fatalError()
  }
}

struct _YYJSONKeyedEncodingContainerProtocol<Key: CodingKey>: KeyedEncodingContainerProtocol {

  let object: MutableJSONValue.Object

  let codingPath: [CodingKey]

  mutating func put(key: Key, value: MutableJSONValue) throws {
    try object.put(key: object.rawValue.document.create(string: key.stringValue).unwrap(), value: value)
  }

  mutating func encodeNil(forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.createNull().unwrap())
  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(value).unwrap())
  }

  mutating func encode(_ value: String, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(string: value).unwrap())
  }

  mutating func encode(_ value: Double, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(value).unwrap())
  }

  mutating func encode(_ value: Float, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(Double(value)).unwrap())
  }

  mutating func encode(_ value: Int, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(Int64(value)).unwrap())
  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(value).unwrap())
  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(UInt64(value)).unwrap())
  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    try put(key: key, value: object.rawValue.document.create(value).unwrap())
  }

  mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
//    print("encoding nested: \(value)")
    let encoder = _YYJSONEncoder(doc: object.rawValue.document, codingPath: codingPath, userInfo: .init())
    try value.encode(to: encoder)
    if let result = encoder.result {
//      print(result)
      try put(key: key, value: result)
    }
  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    let nested = try! object.rawValue.document.createObject().unwrap()
    try! put(key: key, value: nested)

    return .init(_YYJSONKeyedEncodingContainerProtocol<NestedKey>(object: nested.object!, codingPath: codingPath))
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    let nested = try! object.rawValue.document.createArray().unwrap()
    try! put(key: key, value: nested)

    return _YYJSONUnkeyedEncodingContainer(array: nested.array!, codingPath: codingPath)
  }

  mutating func superEncoder() -> Encoder {
    fatalError()
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    fatalError()
  }

}
