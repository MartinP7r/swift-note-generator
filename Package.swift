// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DaybookGen",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(name: "daybook-gen", targets: ["daybook-gen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "daybook-gen",
            dependencies: [ 
                "Files", 
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        // .testTarget(
        //     name: "DaybookGenTests",
        //     dependencies: ["DaybookGen"]),
    ]
)
