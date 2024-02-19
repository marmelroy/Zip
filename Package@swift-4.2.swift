// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Zip",
    products: [
        .library(name: "Zip", targets: ["Zip"])
    ],
    targets: [
        .systemLibrary(
            name: "CZlib",
            path: "Zip/zlib",
            pkgConfig: "zlib"),
        .target(
            name: "Minizip",
            dependencies: ["CZlib"],
            path: "Zip/minizip",
            exclude: ["module"]),
        .target(
            name: "Zip",
            dependencies: ["Minizip"],
            path: "Zip",
            exclude: ["minizip", "zlib"]),
        .testTarget(
            name: "ZipTests",
            dependencies: ["Zip"],
            path: "ZipTests"),
    ]
)
