import yyjson
import JSON

public enum YYJSONEncoderError: Error, CustomStringConvertible {
  case yyjsonWriteError(code: UInt32, message: String)
  case allocateDoc
//  case numberOverflow(source: Any, target: Any.Type)
//  case typeMismatch
  case nullNonCopyString
  case unknown
//  case keyNotFound(CodingKey, DecodingError.Context)

  internal static func yyjsonWriteError(_ error: yyjson_write_err) -> Self {
    .yyjsonWriteError(code: error.code, message: error.msg.map(String.init(cString:)) ?? "")
  }

  public var description: String {
    switch self {
    case .yyjsonWriteError(code: let code, message: let msg):
      return "Code: \(code), message: \(msg)"
//    case .numberOverflow(source: let source, target: let target):
//      return "Can't convert number \(source) to \(target)"
//    case .typeMismatch:
//      return "Type mismatch"
    default: return ""
//    case let .keyNotFound(key, context):
//      return "Key \(key) is not found in context: \(context)"
    }
  }
}

extension YYJSONEncoder {
  
}

func writeString(doc: UnsafeMutablePointer<yyjson_doc>, flag: JSON.WriteOptions) throws -> String {
  var length = 0
  var error = yyjson_write_err()
  if let cstr = yyjson_write_opts(doc, flag.rawValue, nil, &length, &error) {
    let str = String(bytesNoCopy: cstr, length: length, encoding: .utf8, freeWhenDone: true)
    assert(str != nil, "Why?")
    if str == nil {
      throw YYJSONEncoderError.nullNonCopyString
    }
    return str!
  }
  throw YYJSONEncoderError.yyjsonWriteError(error)
}

func writeString(doc: UnsafeMutablePointer<yyjson_mut_doc>, flag: JSON.WriteOptions) throws -> String {
  var length = 0
  var error = yyjson_write_err()
  if let cstr = yyjson_mut_write_opts(doc, flag.rawValue, nil, &length, &error) {
    let str = String(bytesNoCopy: cstr, length: length, encoding: .utf8, freeWhenDone: true)
    assert(str != nil, "Why?")
    if str == nil {
      throw YYJSONEncoderError.nullNonCopyString
    }
    return str!
  }
  throw YYJSONEncoderError.yyjsonWriteError(error)
}

private func writeFile(path: UnsafePointer<Int8>, doc: UnsafeMutablePointer<yyjson_doc>?,
               flag: JSON.WriteOptions, alc: UnsafeMutablePointer<yyjson_alc>?)
throws {
  var error = yyjson_write_err()
  let succ = yyjson_write_file(path, doc, flag.rawValue, alc, &error)
  if !succ {
    throw YYJSONEncoderError.yyjsonWriteError(error)
  }
}

func writeFile(path: UnsafePointer<Int8>, doc: UnsafeMutablePointer<yyjson_mut_doc>?,
               flag: JSON.WriteOptions, alc: UnsafeMutablePointer<yyjson_alc>?)
throws {
  var error = yyjson_write_err()
  let succ = yyjson_mut_write_file(path, doc, flag.rawValue, alc, &error)
  if !succ {
    throw YYJSONEncoderError.yyjsonWriteError(error)
  }
}

public struct YYJSONEncoder {

  public var flag: JSON.WriteOptions

  public init(flag: JSON.WriteOptions = .none) {
    self.flag = flag
  }

  public func encode<T>(_ value: T) throws -> String where T : Encodable {
    let encoder = try _YYJSONEncoder()
    try value.encode(to: encoder)

    return try writeString(doc: encoder.doc, flag: flag)
  }

}

class _YYJSONEncoder: Encoder {

  let doc: UnsafeMutablePointer<yyjson_mut_doc>

  init(codingPath: [CodingKey] = []) throws {
    guard let doc = yyjson_mut_doc_new(nil) else {
      throw YYJSONEncoderError.allocateDoc
    }
    self.doc = doc
    self.codingPath = codingPath
  }

  deinit {
    yyjson_mut_doc_free(doc)
  }

  var codingPath: [CodingKey]

  var userInfo: [CodingUserInfoKey : Any] { fatalError() }

  func checkRootIsNull() {
    assert(doc.pointee.root == nil, "The root is not null, this call will overwrite it")
  }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    checkRootIsNull()
    fatalError()
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    checkRootIsNull()
    let container = try! _YYJSONUnkeyedEncodingContainer(doc: doc, codingPath: codingPath)
    defer {
      yyjson_mut_doc_set_root(doc, container.arr)
    }
    return container
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    checkRootIsNull()
    fatalError()
  }
}

struct _YYJSONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
  mutating func encode(_ value: String) throws {
    precondition(yyjson_mut_arr_add_strcpy(doc, arr, value))
  }

  mutating func encode(_ value: Double) throws {
    precondition(yyjson_mut_arr_add_real(doc, arr, value))
  }

  mutating func encode(_ value: Float) throws {
    precondition(yyjson_mut_arr_add_real(doc, arr, Double(value)))
  }

  mutating func encode(_ value: Int) throws {
    precondition(yyjson_mut_arr_add_int(doc, arr, Int64(value)))
  }

  mutating func encode(_ value: Int8) throws {
    precondition(yyjson_mut_arr_add_int(doc, arr, Int64(value)))
  }

  mutating func encode(_ value: Int16) throws {
    precondition(yyjson_mut_arr_add_int(doc, arr, Int64(value)))
  }

  mutating func encode(_ value: Int32) throws {
    precondition(yyjson_mut_arr_add_int(doc, arr, Int64(value)))
  }

  mutating func encode(_ value: Int64) throws {
    precondition(yyjson_mut_arr_add_int(doc, arr, Int64(value)))
  }

  mutating func encode(_ value: UInt) throws {
    precondition(yyjson_mut_arr_add_uint(doc, arr, UInt64(value)))
  }

  mutating func encode(_ value: UInt8) throws {
    precondition(yyjson_mut_arr_add_uint(doc, arr, UInt64(value)))
  }

  mutating func encode(_ value: UInt16) throws {
    precondition(yyjson_mut_arr_add_uint(doc, arr, UInt64(value)))
  }

  mutating func encode(_ value: UInt32) throws {
    precondition(yyjson_mut_arr_add_uint(doc, arr, UInt64(value)))
  }

  mutating func encode(_ value: UInt64) throws {
    precondition(yyjson_mut_arr_add_uint(doc, arr, UInt64(value)))
  }

  mutating func encode<T>(_ value: T) throws where T : Encodable {
    
  }

  mutating func encode(_ value: Bool) throws {
    precondition(yyjson_mut_arr_add_bool(doc, arr, value))
  }

  var count: Int {
    fatalError()
  }

  mutating func encodeNil() throws {
    precondition(yyjson_mut_arr_add_null(doc, arr))
  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError()
  }

  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError()
  }

  mutating func superEncoder() -> Encoder {
    fatalError()
  }


//  let decoder: _YYJSONDecoder
//
//  var ite: yyjson_arr_iter
  let doc: UnsafeMutablePointer<yyjson_mut_doc>
  let arr: UnsafeMutablePointer<yyjson_mut_val>

  var codingPath: [CodingKey]

  init(
//    decoder: _YYJSONDecoder,
    doc: UnsafeMutablePointer<yyjson_mut_doc>,
    codingPath: [CodingKey]) throws {
//    self.decoder = decoder
    self.doc = doc
    self.arr = yyjson_mut_arr(doc)!
    self.codingPath = codingPath
  }
}

struct _YYJSONKeyedEncodingContainerProtocol<Key: CodingKey>: KeyedEncodingContainerProtocol {

  let doc: UnsafeMutablePointer<yyjson_mut_doc>
  let dic: UnsafeMutablePointer<yyjson_mut_val>

  var codingPath: [CodingKey]

  init(
    //    decoder: _YYJSONDecoder,
    doc: UnsafeMutablePointer<yyjson_mut_doc>,
    codingPath: [CodingKey]) throws {
    //    self.decoder = decoder
    self.doc = doc
    self.dic = yyjson_mut_obj(doc)!
    self.codingPath = codingPath
  }

  mutating func encodeNil(forKey key: Key) throws {

  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {

  }

  mutating func encode(_ value: String, forKey key: Key) throws {

  }

  mutating func encode(_ value: Double, forKey key: Key) throws {

  }

  mutating func encode(_ value: Float, forKey key: Key) throws {

  }

  mutating func encode(_ value: Int, forKey key: Key) throws {

  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {

  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {

  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {

  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {

  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {

  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {

  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {

  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {

  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {

  }

  mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {

  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError()
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError()
  }

  mutating func superEncoder() -> Encoder {
    fatalError()
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    fatalError()
  }


  
}
