// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "EnergyKit",
    products: [
        .library(
            name: "EnergyKit",
            targets: ["EnergyKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/MillerTechnologyPeru/MPPSolar.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/TLVCoding.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "EnergyKit",
            dependencies: [
                "TLVCoding",
                "MPPSolar"
            ]
        ),
        .testTarget(
            name: "EnergyKitTests",
            dependencies: ["EnergyKit"]
        ),
    ]
)
