import yyjson
import Foundation

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

func safeYYRead(dat: UnsafeMutablePointer<Int8>?, count: Int,
                flag: YYJSONDecoder.ReadFlags, alc: UnsafeMutablePointer<yyjson_alc>?)
throws -> UnsafeMutablePointer<yyjson_doc> {
  var error = yyjson_read_err()
  guard let doc = yyjson_read_opts(dat, count, flag.rawValue & ~YYJSON_READ_INSITU, alc, &error) else {
    throw YYJSONDecodeError.yyjsonReadError(error)
  }
  return doc
}

extension YYJSONDecoder {
  public struct ReadFlags: OptionSet {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }

    public static let none = Self(rawValue: YYJSON_READ_NOFLAG)
    public static let inSitu = Self(rawValue: YYJSON_READ_INSITU)
    //    public static let fastFP = Self(rawValue: YYJSON_READ_FASTFP)
    public static let stopWhenDone = Self(rawValue: YYJSON_READ_STOP_WHEN_DONE)
    public static let allowTrailingCommas = Self(rawValue: YYJSON_READ_ALLOW_TRAILING_COMMAS)
    public static let allowComments = Self(rawValue: YYJSON_READ_ALLOW_COMMENTS)
    public static let allowInfAndNan = Self(rawValue: YYJSON_READ_ALLOW_INF_AND_NAN)
  }
}

public struct YYJSONDecoder {

  public var flag: ReadFlags

  public init(flag: ReadFlags = .none) {
    self.flag = flag
  }

  public func decode<T: Decodable>(_ type: T.Type = T.self, from doc: UnsafeMutablePointer<yyjson_doc>) throws -> T {
    try T(from: _YYJSONDecoder(root: doc.pointee.root, codingPath: [], userInfo: .init()))
  }

  public func decode<T: Decodable>(_ type: T.Type = T.self, from string: String) throws -> T {
    var copy = string
    let doc = try copy.withUTF8 { buffer in
      try buffer.withMemoryRebound(to: Int8.self) { i8Buffer in
        try safeYYRead(dat: i8Buffer.baseAddress.map(UnsafeMutablePointer.init),
                       count: i8Buffer.count, flag: flag, alc: nil)
      }
    }

    defer { yyjson_doc_free(doc) }
    return try decode(T.self, from: doc)
  }

  public func decode<T: Decodable, D: ContiguousBytes>(_ type: T.Type = T.self, from data: D) throws -> T {
    let doc = try data.withUnsafeBytes { buffer -> UnsafeMutablePointer<yyjson_doc> in
      let dat = buffer.bindMemory(to: Int8.self)
      return try safeYYRead(dat: dat.baseAddress.map(UnsafeMutablePointer.init), count: dat.count, flag: flag, alc: nil)
    }
    defer { yyjson_doc_free(doc) }
    return try decode(T.self, from: doc)
  }
}

struct _YYJSONDecoder: Decoder {

  init(root: UnsafeMutablePointer<yyjson_val>, codingPath: [CodingKey],
       userInfo: [CodingUserInfoKey : Any]) {
    self.root = root
    self.codingPath = codingPath
    self.userInfo = userInfo
  }

  let root: UnsafeMutablePointer<yyjson_val>

  var codingPath: [CodingKey]

  var userInfo: [CodingUserInfoKey : Any]

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    precondition(yyjson_is_obj(root))
    return .init(_YYJSONKeyedDecodingContainer<Key>(decoder: self))
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    precondition(yyjson_is_arr(root))
    return _YYJSONUnkeyedDecodingContainer(decoder: self, codingPath: codingPath)
  }

  func singleValueContainer() throws -> SingleValueDecodingContainer {
    self
  }

}

struct _YYJSONKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

  let decoder: _YYJSONDecoder

  init(decoder: _YYJSONDecoder) {
    self.decoder = decoder
  }

  var codingPath: [CodingKey] {
    decoder.codingPath
  }

  var allKeys: [Key] {
    var iter = yyjson_obj_iter()
    yyjson_obj_iter_init(decoder.root, &iter)
    var keys = [Key]()
    keys.reserveCapacity(unsafe_yyjson_get_len(decoder.root))
    while let key = yyjson_obj_iter_next(&iter) {
      Key(stringValue: String(cString: yyjson_get_str(key))).map{ keys.append($0) }
    }
    return keys
  }

  #warning("should throw error")
  func value(for key: Key) throws -> UnsafeMutablePointer<yyjson_val> {
    yyjson_obj_get(decoder.root, key.stringValue)!
  }

  func decoder(for key: Key) throws -> _YYJSONDecoder {
    try .init(root: value(for: key), codingPath: codingPath + CollectionOfOne(key as CodingKey), userInfo: decoder.userInfo)
  }

  func contains(_ key: Key) -> Bool {
    yyjson_obj_get(decoder.root, key.stringValue) != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    try yyjson_is_null(value(for: key))
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

  let decoder: _YYJSONDecoder

  var ite: yyjson_arr_iter

  var codingPath: [CodingKey]

  init(
    decoder: _YYJSONDecoder,
    codingPath: [CodingKey]) {
    self.decoder = decoder
    self.codingPath = codingPath
    ite = .init()
    precondition(yyjson_arr_iter_init(decoder.root, &ite))
  }

  var count: Int? {
    ite.max
  }

  var isAtEnd: Bool {
    ite.idx >= ite.max
  }

  var currentIndex: Int {
    ite.idx
  }

  #warning("throw at end error")
  mutating func nextElement() throws -> UnsafeMutablePointer<yyjson_val> {
    yyjson_arr_iter_next(&ite)!
  }

  #warning("throw at end error")
  mutating func nextElementDecoder() throws -> _YYJSONDecoder {
    try .init(root: nextElement(), codingPath: [], userInfo: .init())
  }

  mutating func decodeNil() throws -> Bool {
    try yyjson_is_null(nextElement())
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

extension _YYJSONDecoder: SingleValueDecodingContainer {

  func decodeNil() -> Bool {
    yyjson_is_null(root)
  }

  func decode(_ type: Bool.Type) throws -> Bool {
    guard unsafe_yyjson_is_bool(root) else {
      throw YYJSONDecodeError.typeMismatch
    }
    return unsafe_yyjson_get_bool(root)
  }

  func decode(_ type: String.Type) throws -> String {
    guard unsafe_yyjson_is_str(root) else {
      throw YYJSONDecodeError.typeMismatch
    }
    return String(cString: unsafe_yyjson_get_str(root))
  }

  func decode(_ type: Double.Type) throws -> Double {
    try getDouble()
  }

  func decode(_ type: Float.Type) throws -> Float {
    let double = try decode(Double.self)
    if abs(double) <= Double(Float.greatestFiniteMagnitude) {
      throw YYJSONDecodeError.numberOverflow(source: double, target: Float.self)
    }
    return Float(double)
  }

  func decode(_ type: Int.Type) throws -> Int {
    try convertInteger()
  }

  func decode(_ type: Int8.Type) throws -> Int8 {
    try convertInteger()
  }

  func decode(_ type: Int16.Type) throws -> Int16 {
    try convertInteger()
  }

  func decode(_ type: Int32.Type) throws -> Int32 {
    try convertInteger()
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    try getInt64()
  }

  func decode(_ type: UInt.Type) throws -> UInt {
    try convertInteger()
  }

  func decode(_ type: UInt8.Type) throws -> UInt8 {
    try convertInteger()
  }

  func decode(_ type: UInt16.Type) throws -> UInt16 {
    try convertInteger()
  }

  func decode(_ type: UInt32.Type) throws -> UInt32 {
    try convertInteger()
  }

  func decode(_ type: UInt64.Type) throws -> UInt64 {
    try getUInt64()
  }

  func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
    try .init(from: self)
  }

}

// MARK: Number convertion
extension _YYJSONDecoder {

  func convertInteger<Output: FixedWidthInteger>() throws -> Output {

    func convert<Input: FixedWidthInteger, Output: FixedWidthInteger>(_ input: Input) throws -> Output {
      guard let number = Output(exactly: input) else {
        throw YYJSONDecodeError.numberOverflow(source: input, target: Output.self)
      }
      return number
    }

    if unsafe_yyjson_is_sint(root) {
      return try convert(unsafe_yyjson_get_sint(root))
    } else if unsafe_yyjson_is_uint(root) {
      return try convert(unsafe_yyjson_get_uint(root))
    } else {
      throw YYJSONDecodeError.typeMismatch
    }
  }

  func getInt64() throws -> Int64 {
    if unsafe_yyjson_is_sint(root) {
      return unsafe_yyjson_get_sint(root)
    } else {
      throw YYJSONDecodeError.typeMismatch
    }
  }

  func getUInt64() throws -> UInt64 {
    if unsafe_yyjson_is_uint(root) {
      return unsafe_yyjson_get_uint(root)
    } else {
      throw YYJSONDecodeError.typeMismatch
    }
  }

  func getDouble() throws -> Double {
    guard unsafe_yyjson_is_num(root) else {
      throw YYJSONDecodeError.typeMismatch
    }
    if unsafe_yyjson_is_real(root) {
      return unsafe_yyjson_get_real(root)
    } else if unsafe_yyjson_is_uint(root) {
      return Double(unsafe_yyjson_get_uint(root))
    }
    return Double(unsafe_yyjson_get_sint(root))
  }
}
