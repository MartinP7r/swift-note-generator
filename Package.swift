// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DaybookGen",
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "DaybookGen",
            dependencies: [ 
                "Files", 
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        // .testTarget(
        //     name: "DaybookGenTests",
        //     dependencies: ["DaybookGen"]),
    ]
)
