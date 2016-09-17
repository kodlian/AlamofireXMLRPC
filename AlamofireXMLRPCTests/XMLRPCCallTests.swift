//
//  XMLRPCCallTests.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import XCTest
@testable import AlamofireXMLRPC
import Alamofire

class XMLRPCCallTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCall() {

        let parameters: [Any] = [
            "Hello",
            42,
            3.14,
            true, iso8601DateFormatter.date(from: "19870513T08:27:30")!,
            "Valar morghulis".data(using: String.Encoding.utf8)!,
            ["name":"John Doe"] as XMLRPCStructure

        ]

        let path = Bundle(for: XMLRPCCallTests.self).path(forResource: "call", ofType: "xml", inDirectory: nil)!

        let text = try! String(contentsOfFile: path, encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet(charactersIn: "\t\n"))

        let call = XMLRPCCallDocument(methodName: "hello", parameters: parameters)

        XCTAssertEqual(call.xmlCompact, text)

        print(call.xmlCompact)

    }


}
