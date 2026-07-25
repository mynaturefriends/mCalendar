// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "mCalendar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "mCalendar",
            path: "Sources/mCalendar"
        )
    ]
)
