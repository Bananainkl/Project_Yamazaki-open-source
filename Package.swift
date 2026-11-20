// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Yamazaki",
  platforms: [
    .macOS("26.0")
  ],
  products: [
    .executable(name: "Yamazaki", targets: ["FreeScanOCR"])
  ],
  targets: [
    .executableTarget(
      name: "FreeScanOCR",
      dependencies: ["VisionOCRSupport"],
      path: "Sources/FreeScanOCR",
      exclude: ["main (1).swift"]
    ),
    .target(
      name: "VisionOCRSupport",
      path: "Sources/VisionOCRSupport"
    ),
    .testTarget(
      name: "VisionOCRSupportTests",
      dependencies: ["VisionOCRSupport"],
      path: "Tests/VisionOCRSupportTests"
    )
  ]
)
