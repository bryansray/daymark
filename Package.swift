// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "daymark",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "daymark", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                "Core",
                "AppleCalendar",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Rainbow"
            ]
        ),
        .target(
            name: "Core"
        ),
        .target(
            name: "AppleCalendar",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "Core"]
        ),
        .testTarget(
            name: "AppleCalendarTests",
            dependencies: ["AppleCalendar", "Core"]
        )
    ]
)
