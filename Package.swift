// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "YYJSONEncoder",
  products: [
    .library(name: "YYJSONEncoder", targets: ["YYJSONEncoder"]),
    .library(name: "JSON", targets: ["JSON"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ibireme/yyjson.git", .upToNextMajor(from: "0.2.0")),
  ],
  targets: [
    .target(
      name: "JSON",
      dependencies: ["yyjson"]),
    .target(
      name: "YYJSONEncoder",
      dependencies: [
        "yyjson",
        "JSON",
      ]),
    .testTarget(
      name: "JSONTests",
      dependencies: ["JSON"]),
    .testTarget(
      name: "YYJSONEncoderTests",
      dependencies: ["YYJSONEncoder"]),
  ]
)
