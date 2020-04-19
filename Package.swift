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
            url: "https://github.com/PureSwift/TLVCoding.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/Predicate.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift",
            .branch("master")
        ),
        .package(
            url: "https://github.com/uraimo/SwiftyGPIO.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMinor(from: "0.0.1")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothLinux.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothDarwin.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/MillerTechnologyPeru/MPPSolar.git",
            .branch("master")
        ),
    ],
    targets: [
        .target(
            name: "EnergyKit",
            dependencies: [
                "Bluetooth",
                "GATT",
                "TLVCoding",
                "CryptoSwift",
                "Predicate"
            ]
        ),
        .target(
            name: "energykit-mppsolar",
            dependencies: [
                "EnergyKit",
                "MPPSolar",
                "ArgumentParser",
                "GATT",
                "DarwinGATT",
                "BluetoothLinux",
                "BluetoothDarwin"
            ]
        ),
        .target(
            name: "energykit-accessory",
            dependencies: [
                "EnergyKit",
                "ArgumentParser",
                "GATT",
                "DarwinGATT",
                "BluetoothLinux",
                "BluetoothDarwin"
            ]
        ),
        .target(
            name: "energykit-controller",
            dependencies: [
                "EnergyKit",
                "ArgumentParser",
                "GATT",
                "DarwinGATT",
                "BluetoothLinux",
                "BluetoothDarwin"
            ]
        ),
        .testTarget(
            name: "EnergyKitTests",
            dependencies: ["EnergyKit"]
        ),
    ]
)
