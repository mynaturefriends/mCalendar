// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZCalendar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ZCalendar",
            path: "Sources/ZCalendar"
        )
    ]
)
