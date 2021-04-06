//
//  XMLRPCCallTests.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import XCTest
import Alamofire
@testable import AlamofireXMLRPC

class XMLRPCCallTests: XCTestCase {
    func testCall() {
        let parameters: [Any] = [
            "Hello",
            42,
            3.14,
            true, iso8601DateFormatter.date(from: "19870513T08:27:30")!,
            "Valar morghulis".data(using: String.Encoding.utf8)!,
            ["name": "John Doe"]
        ]

        let path = Bundle(for: XMLRPCCallTests.self).path(forResource: "call", ofType: "xml", inDirectory: nil)!

        guard let text = try? String(contentsOfFile: path, encoding: .utf8)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\t\n"))
        else {
            XCTFail("reading contents of file '\(path)' failed")
            return
        }

        let call = XMLRPCCallDocument(methodName: "hello", parameters: parameters)

        XCTAssertEqual(call.xmlCompact, text)

        print(call.xmlCompact)
    }
}
