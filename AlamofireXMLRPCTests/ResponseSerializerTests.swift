//
//  XMLRPCSerializerTests.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import XCTest
@testable import AlamofireXMLRPC
import Alamofire

class ResponseSerializerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    fileprivate func serialize(_ name: String) -> Result<XMLRPCNode> {
        let url = Bundle(for: ResponseSerializerTests.self).url(forResource: name, withExtension: "xml", subdirectory: nil)!
        let data = try? Data(contentsOf: url)
        return DataRequest.XMLRPCResponseSerializer().serializeResponse(nil, nil, data, nil)
    }

    func testParams() {
        let result = serialize("testParams")

        XCTAssertNil(result.error)

        guard let node = result.value else {
            XCTFail()
            return
        }

        XCTAssertEqual(node[0].string, "Hello")
        XCTAssertEqual(node[1].string, "Hello Again")
        XCTAssertNil(node[1].int32)

        XCTAssertEqual(node[2].int32, 42)
        XCTAssertEqual(node[3].int32, 42)
        XCTAssertNil(node[2].string)

        XCTAssertEqual(node[4].double, 3.14)
        XCTAssertNil(node[4].string)

        XCTAssertEqual(node[5].bool, true)
        XCTAssertNil(node[5].string)

        XCTAssertEqual(node[6].date, iso8601DateFormatter.date(from: "19870513T08:27:30"))
        XCTAssertNil(node[6].string)

        XCTAssertEqual(node[7].data, "Valar morghulis".data(using: String.Encoding.utf8))
        XCTAssertNil(node[7].string)

    }

    func testStructParam() {
        let result = serialize("testStructParam")

        XCTAssertNil(result.error)
        XCTAssertNil(result.value?[0].dictionary)
        XCTAssertNotNil(result.value?[1].dictionary)

        guard let node = result.value?[1] else {
            XCTFail()
            return
        }

        XCTAssertEqual(node["name"].string, "John Doe")
        XCTAssertEqual(node["age"].int32, 32)
        XCTAssertNil(node["notExist"].string)
        XCTAssertNotNil(node[0].error)

    }


    func testArrayParam() {
        let result = serialize("testArrayParam")

        XCTAssertNil(result.error)
        XCTAssertNil(result.value?[0].array)
        XCTAssertNotNil(result.value?[1].array)
        XCTAssertEqual(result.value?[1].count, 2)

        guard let node = result.value?[1] else {
            XCTFail()
            return
        }

        XCTAssertEqual(node[0].int32, 42)
        XCTAssertEqual(node[1].double, 1.61)
        XCTAssertNotNil(node["aKey"].error)

        var counter = 0
        for _ in node {
            counter += 1
        }
        XCTAssertEqual(counter, 2)
    }

    func testFault() {
        let result = serialize("testFault")

        guard let error = result.error else {
            XCTFail()
            return
        }

        switch error {
        case XMLRPCError.fault(node: let node):
            XCTAssertEqual(node.string, "No such method!")
        default:
            XCTFail()

        }

    }

    func testFaultStruct() {
        let result = serialize("testFaultStruct")

        guard let error = result.error else {
            XCTFail()
            return
        }

        switch error {
        case XMLRPCError.fault(node: let node):
            XCTAssertEqual(node["code"].int32, 26)
            XCTAssertEqual(node["message"].string, "No such method!")
        default:
            XCTFail()
        }
    }

}
