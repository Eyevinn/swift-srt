// swift-tools-version:5.3
 
import PackageDescription
 
let package = Package(
    name: "SwiftSRT",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftSRT",
            targets: ["SwiftSRT"]),
    ],
    targets: [
        .binaryTarget(
            name: "SwiftSRT",
            path: "build/SwiftSRT.xcframework"
        )
    ]
)
