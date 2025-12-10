// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ErrorInfo",
  platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .macCatalyst(.v18), .watchOS(.v11), .visionOS(.v2)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "ErrorInfo", targets: ["ErrorInfo"]),
  ],
  dependencies: [
    .package(url: "https://github.com/iDmitriyy/SwiftCollections-NonEmpty.git", branch: "RangeSet"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "ErrorInfo", dependencies: [
      .product(name: "SwiftCollectionsNonEmpty", package: "swiftCollections-nonEmpty"),
      .product(name: "GeneralizedCollections", package: "swiftCollections-nonEmpty"),
    ]),
    .testTarget(name: "ErrorInfoTests", dependencies: [.target(name: "ErrorInfo")]),
    .testTarget(name: "ErrorInfoPerfomanceTests", dependencies: [.target(name: "ErrorInfo")]),
  ],
  swiftLanguageModes: [.v6],
)

for target: PackageDescription.Target in package.targets {
  {
    var settings: [PackageDescription.SwiftSetting] = $0 ?? []
    settings.append(.enableUpcomingFeature("ExistentialAny"))
    settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
    settings.append(.enableUpcomingFeature("MemberImportVisibility"))
    settings.append(.enableExperimentalFeature("Lifetimes"))
    settings.append(.enableExperimentalFeature("LifetimeDependence"))
    settings.append(.enableExperimentalFeature("CompileTimeValues"))
    $0 = settings
  }(&target.swiftSettings)
}

// -enable-module-selectors-in-module-interface flag to the OTHER_SWIFT_FLAGS build setting.
