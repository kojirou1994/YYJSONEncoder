import XCTest
@testable import YYJSONEncoder

final class YYJSONEncoderTests: XCTestCase {
  func testExample() throws {

    struct A: Codable {
      let int: UInt8
      let str: String
      let b: [B]
    }
    struct B: Codable {
      let uint: UInt
      let str: String
    }
    let json = """
    {
    "int": \(numericCast(Int8.max) + 1),
    "str": "ABCD",
    "b": [{
    "uint": \(Int.max),
    "str": "ABCD",
    }],
    }
    """
    let decoder = YYJSONDecoder(flag: [.allowTrailingCommas])

    XCTAssertNoThrow(try decoder.decode(from: json) as A)

  }
}
