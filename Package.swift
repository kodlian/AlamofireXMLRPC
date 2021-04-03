// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "AlamofireXMLRPC",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire", majorVersion: 5),
        .Package(url: "https://github.com/tadija/AEXML.git", majorVersion: 4)
    ]
)

