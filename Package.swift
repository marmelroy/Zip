// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "Zip",
    products: [
        .library(name: "Zip", targets: ["Zip"])
    ],
    targets: [
        .target(
            name: "Minizip",
            dependencies: [],
            path: "Zip/minizip",
            exclude: ["module"],
            cSettings: [
                .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
            ]),
        .target(
            name: "Zip",
            dependencies: ["Minizip"],
            path: "Zip",
            exclude: ["minizip", "zlib"],
            cSettings: [
                .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
            ]),
        .testTarget(
            name: "ZipTests",
            dependencies: ["Zip"],
            path: "ZipTests"),
    ]
)

if let target = package.targets.filter({ $0.name == "Minizip" }).first {
#if os(Windows)
    if ProcessInfo.processInfo.environment["ZIP_USE_DYNAMIC_ZLIB"] == nil {
        target.cSettings?.append(contentsOf: [.define("ZLIB_STATIC")])
        target.linkerSettings = [.linkedLibrary("zlibstatic")]
    } else {
        target.linkerSettings = [.linkedLibrary("zlib")]
    }
#else
    target.linkerSettings = [.linkedLibrary("z")]
#endif
}
