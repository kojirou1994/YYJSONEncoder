import yyjson

public final class MutableJSON {
  internal init(doc: UnsafeMutablePointer<yyjson_mut_doc>) {
    self.doc = doc
  }


  let doc: UnsafeMutablePointer<yyjson_mut_doc>

  deinit {
    yyjson_mut_doc_free(doc)
  }
}

// MARK: Mutable JSON Value Creation API
public extension MutableJSON {
  func null() throws -> Int {
    0
  }
}

public extension MutableJSON {

//  var root: JSONValue {
//    .init(val: yyjson_mut_doc_get_root(doc), doc: self)
//  }

}
