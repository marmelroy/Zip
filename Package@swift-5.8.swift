// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let defines: [SwiftSetting] = [
    .define("SYSTEM_ICONV", .when(platforms: [.linux]))
]

#if os(Linux)
let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/0xfeedface1993/iconv.git", branch: "main"),
    .package(url: "https://github.com/0xfeedface1993/CEnca.git", from: "0.1.3"),
]
let products: [Target.Dependency] = [
    .product(name: "iconv", package: "iconv"),
    .product(name: "EncodingWrapper", package: "CEnca"),
]
#else
let dependencies: [PackageDescription.Package.Dependency] = []
let products: [Target.Dependency] = []
#endif

let package = Package(
    name: "Zip",
    products: [
        .library(name: "Zip", targets: ["Zip"])
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Minizip",
            dependencies: [],
            path: "Zip/minizip",
            exclude: ["module"],
            linkerSettings: [
                .linkedLibrary("z")
            ]),
        .target(
            name: "Zip",
            dependencies: ["Minizip"] + products,
            path: "Zip",
            exclude: ["minizip", "zlib"]),
        .testTarget(
            name: "ZipTests",
            dependencies: ["Zip"],
            path: "ZipTests",
            resources: [.process("Resources")]),
    ]
)
