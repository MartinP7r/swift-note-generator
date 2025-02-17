// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NoteGen",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "note-gen", targets: ["note-gen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/martinp7r/swift-argument-parser", branch: "test_lib"),
    ],
    targets: [
        .executableTarget(
            name: "note-gen",
            dependencies: [
                "Files",
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "NoteGenTests",
            dependencies: [
                "note-gen",
                .product(name: "ArgumentParserTestHelpers", package: "swift-argument-parser")
//                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                // Copy Tests/ExampleTests/Resources directories as-is.
                // Use to retain directory structure.
                // Will be at top level in bundle.
                .copy("Resources"),
            ]),
    ]
)
