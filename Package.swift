// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "YYJSONEncoder",
  products: [
    .library(name: "JSON", targets: ["JSON"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ibireme/yyjson.git", .upToNextMinor(from: "0.7.0")),
    .package(url: "https://github.com/kojirou1994/Precondition.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/kojirou1994/CUtility.git", .upToNextMajor(from: "0.0.1")),
  ],
  targets: [
    .target(
      name: "JSON",
      dependencies: [
        .product(name: "yyjson", package: "yyjson"),
        .product(name: "Precondition", package: "Precondition"),
        .product(name: "CUtility", package: "CUtility"),
      ]),
    .target(
      name: "YYJSONEncoder",
      dependencies: [
        "yyjson",
        "JSON",
      ]),
    .executableTarget(
      name: "ExecC",
      dependencies: [
        "yyjson",
      ]),
    .executableTarget(
      name: "ExecSwift",
      dependencies: [
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
