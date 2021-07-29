import XCTest
@testable import YYJSONEncoder
import yyjson

final class YYJSONEncoderTests: XCTestCase {
  func testExample() throws {
    struct A: Encodable {
      let str: String
    }

    let encoder = YYJSONEncoder()
    print(try encoder.encode([1,2,3]))
    //    try encoder.encode(A(str: "A啊"))
  }

  func testEncodeDoc() throws {
    let doc = yyjson_mut_doc_new(nil)!

    let encoder = YYJSONEncoder(flag: [.pretty])
    let arr = yyjson_mut_arr(doc)!
    /*
     let doc: UnsafeMutablePointer<yyjson_mut_doc>
     let arr: UnsafeMutablePointer<yyjson_mut_val>
     */

    yyjson_mut_arr_add_false(doc, arr)

    let subArr = yyjson_mut_arr_add_arr(doc, arr)!

    yyjson_mut_arr_add_strcpy(doc, subArr, "ABCD你好")
    yyjson_mut_arr_add_strcpy(doc, arr, "你好ABCD")

    yyjson_mut_doc_set_root(doc, arr)

    let obj = yyjson_mut_arr_add_obj(doc, arr)!
    //    let str = "Key" as NSString
    let rawStr = String(repeating: "Key", count: 1000)
    //    while true {
    let str = yyjson_mut_strcpy(doc, rawStr)!
    yyjson_mut_obj_add_int(doc, obj, str.pointee.uni.str, 1)

    //    var copystr: UnsafeMutablePointer<Int8>!
    //      copystr = strdup(cstr)
    //      yyjson_mut_obj_add_int(doc, obj, copystr, 1)
    //      yyjson_mut_obj_add_int(doc, obj, rawStr, 1)
    //    }

    let encoded = try writeString(doc: doc, flag: encoder.flag)
    print(encoded)
    yyjson_mut_doc_free(doc)
    //    copystr.deallocate()

    //    print(strlen(copystr))
  }

}
