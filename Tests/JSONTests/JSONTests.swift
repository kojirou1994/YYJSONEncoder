import XCTest
@testable import JSON

final class JSONTests: XCTestCase {
  func testExample() throws {
    let str = """
{
    "size" : 3,
    "users" : [
        {"id": 1, "name": "Harry"},
        {"id": 2, "name": "Ron"},
        {"id": 3, "name": "Hermione"}
    ]
}
"""
    let json = try JSON.read(string: str)
//    print(json.root["size"].int)
//    print(json.root["users"][2]["name"].string)
    json.root.object?.forEach { element in
      print(element.key.string, element.value)
    }

    json.root.get(pointer: "/size/users").array?.forEach({ v in
      print(v)
    })
  }
}
