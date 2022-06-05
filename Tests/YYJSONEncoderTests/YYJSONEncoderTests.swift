import XCTest
import YYJSONEncoder

final class YYJSONEncoderTests: XCTestCase {

  struct AutomatedModel<T: Codable & Equatable>: Codable, Equatable {
    let single: T
    let unkeyed: [T]
    let unkeyedNestedUnkeyed: [[T]]
    let nestedKeyed: NestedKeyed

    struct NestedKeyed: Codable, Equatable {
      let single: T

      init(_ value: T) {
        single = value
      }
    }

    init(_ value: T) {
      single = value
      unkeyed = .init(repeating: value, count: 100)
      unkeyedNestedUnkeyed = .init(repeating: unkeyed, count: 100)
      nestedKeyed = .init(value)
    }
  }

  func encodeAndDecodeAutomated<T: Codable & Equatable>(_ value: T) throws {
    // single value
    try encodeAndDecode(value)

    // unkeyed
    try encodeAndDecode(Array(repeating: value, count: 100))

    // keyed
    try encodeAndDecode(AutomatedModel(value))

  }

  func encodeAndDecode<T: Codable & Equatable>(_ value: T) throws {
    let encoded = try YYJSONEncoder().encode(value)
    let decoded = try T(from: YYJSONDecoder(XCTUnwrap(encoded.root)))
    XCTAssertEqual(value, decoded)

    for _ in 1...1_0 {
      _ = try YYJSONEncoder().encode(value)
      _ = try T(from: YYJSONDecoder(encoded.root!))
    }
  }

  func testCoder() throws {
    try encodeAndDecodeAutomated(1 as Int8)
    try encodeAndDecodeAutomated(1 as Int16)
    try encodeAndDecodeAutomated(1 as Int32)
    try encodeAndDecodeAutomated(1 as Int64)
    try encodeAndDecodeAutomated(1 as Int)
    try encodeAndDecodeAutomated(1 as UInt8)
    try encodeAndDecodeAutomated(1 as UInt16)
    try encodeAndDecodeAutomated(1 as UInt32)
    try encodeAndDecodeAutomated(1 as UInt64)
    try encodeAndDecodeAutomated(1 as UInt)
    try encodeAndDecodeAutomated(1 as Float)
    try encodeAndDecodeAutomated(1 as Double)
    try encodeAndDecodeAutomated("ABCD")
    try encodeAndDecodeAutomated(true)
    try encodeAndDecodeAutomated(false)
  }

}
