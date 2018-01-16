// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zip",
    products: [.library(name: "Zip", targets: ["Zip"])],
    targets: [
        .target(
            name: "minizip",
            dependencies: [],
            path: "Zip/minizip"),
        .target(
            name: "Zip",
            dependencies: [ "minizip" ],
            path: "Zip",
            exclude: [ "minizip" ]),
        .testTarget(
            name: "ZipTests",
            dependencies: [],
            path: "ZipTests"),
        ]
)
