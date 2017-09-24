// swift-tools-version:3.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireXMLRPC",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire", majorVersion: 4),
        .Package(url: "https://github.com/tadija/AEXML.git", majorVersion: 4)
    ]
)

