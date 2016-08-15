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

class XMLRPCSerializerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func serialize(name: String) -> Result<XMLRPCNode, XMLRPCError> {
        let path = NSBundle(forClass: XMLRPCSerializerTests.self).pathForResource(name, ofType: "xml", inDirectory: nil)!
        return Request.XMLRPCResponseSerializer().serializeResponse(nil, nil, NSData(contentsOfFile: path), nil)
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
        XCTAssertEqual(node[2].int32, 42)
        XCTAssertEqual(node[3].int32, 42)
        XCTAssertEqual(node[4].double, 3.14)
        XCTAssertEqual(node[5].bool, true)
        XCTAssertEqual(node[7].data, "Valar morghulis".dataUsingEncoding(NSUTF8StringEncoding))
    }

    func testStructParam() {
        let result = serialize("testStructParam")

        XCTAssertNil(result.error)

        guard let node = result.value?[1].dictionary else {
            XCTFail()
            return
        }

        XCTAssertEqual(node["name"]?.string, "John Doe")
        XCTAssertEqual(node["age"]?.int32, 32)
    }


    func testArrayParam() {
        let result = serialize("testArrayParam")

        XCTAssertNil(result.error)

        guard let node = result.value?[1].array else {
            XCTFail()
            return
        }
        XCTAssertEqual(node.count, 2)

        XCTAssertEqual(node[0].int32, 42)
        XCTAssertEqual(node[1].double, 1.61)
    }

    func testFault() {
        let result = serialize("testFault")

        guard let error = result.error else {
            XCTFail()
            return
        }

        switch error {
        case .Fault(node: let node):
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
        case .Fault(node: let node):
            guard let dict = node.dictionary else {
                XCTFail()
                return
            }

            XCTAssertEqual(dict["code"]?.int32, 26)
            XCTAssertEqual(dict["message"]?.string, "No such method!")
        default:
            XCTFail()
        }
    }

}
