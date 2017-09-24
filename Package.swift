// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireXMLRPC",
    products: [
        .library(
            name: "AlamofireXMLRPC",
            targets: ["AlamofireXMLRPC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "4.0.0"),
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "AlamofireXMLRPC",
            dependencies: []),
        .testTarget(
            name: "AlamofireXMLRPCTests",
            dependencies: ["AlamofireXMLRPC"]),
    ]
)
