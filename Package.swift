// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "OpenSSL",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "OpenSSL", targets: ["OpenSSL"]),
        .library(name: "Cacert", targets: ["Cacert"]),
    ],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            path: "OpenSSL.xcframework"
        ),
        .target(
            name: "Cacert",
            dependencies: [
                "OpenSSL",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
