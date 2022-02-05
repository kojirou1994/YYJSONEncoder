import yyjson

for _ in 1...10 {
  CommandLine.arguments.dropFirst().forEach { path in
    let doc = yyjson_read_file(path, YYJSON_READ_NOFLAG, nil, nil)
    for _ in 1...10 {
      free(yyjson_write(doc, YYJSON_WRITE_PRETTY, nil))
    }
    yyjson_doc_free(doc)
  }
}
