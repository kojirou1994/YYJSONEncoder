import JSON
import Foundation

for _ in 1...10 {
  CommandLine.arguments.dropFirst().forEach { path in
    do {
      let doc = try JSON.read(path: path)
      for _ in 1...10 {
        free(try doc.write(options: .pretty, length: nil, allocator: nil))
      }
    } catch {
      fatalError()
    }
  }
}
