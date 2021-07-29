// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "YYJSONEncoder",
  products: [
    .library(
      name: "YYJSONEncoder",
      targets: ["YYJSONEncoder"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ibireme/yyjson.git", .upToNextMajor(from: "0.2.0")),
  ],
  targets: [
    .target(
      name: "YYJSONEncoder",
      dependencies: ["yyjson"]),
    .testTarget(
      name: "YYJSONEncoderTests",
      dependencies: ["YYJSONEncoder"]),
  ]
)
