// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Yamazaki",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(name: "Yamazaki", targets: ["FreeScanOCR"])
  ],
  targets: [
    .executableTarget(
      name: "FreeScanOCR",
      path: "Sources/FreeScanOCR"
    )
  ]
)
