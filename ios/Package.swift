// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaidFinal",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "PlaidFinal",
            targets: ["PlaidFinal"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/plaid/plaid-link-ios-spm.git",
            from: "6.2.1"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "PlaidFinal",
            dependencies: [
                .product(name: "LinkKit", package: "plaid-link-ios-spm")
            ],
            path: "Sources/PlaidFinal"
        )
    ]
)
