//
//  XMLRPCSerializerTests.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import XCTest
import Alamofire
@testable import AlamofireXMLRPC

class XMLRPCResponseSerializerTests: XCTestCase {
    fileprivate func serialize(_ name: String) throws -> XMLRPCNode? {
        let url = Bundle(for: XMLRPCResponseSerializerTests.self).url(
            forResource: name,
            withExtension: "xml",
            subdirectory: nil)!
        let data = try? Data(contentsOf: url)
        return try XMLRPCResponseSerializer().serialize(request: nil, response: nil, data: data, error: nil)
    }

    func testEmptyResponse() {
        let serializer = XMLRPCResponseSerializer()
        let responseURL = URL(string: "http://localhost")!
        let response = HTTPURLResponse(url: responseURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        do {
            _ = try serializer.serialize(request: nil, response: response, data: nil, error: nil)
        } catch XMLRPCError.responseSerializationFailed(let reason) {
            switch reason {
            case .inputDataNilOrZeroLength:
                XCTAssertTrue(true)
            default:
                XCTFail("reason not input data nil or zero length: \(reason)")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEmptyResponseWhenAllowed() {
        let serializer = XMLRPCResponseSerializer()
        let responseURL = URL(string: "http://localhost")!
        let response = HTTPURLResponse(url: responseURL, statusCode: 204, httpVersion: nil, headerFields: nil)

        var result: XMLRPCNode?

        do {
            result = try serializer.serialize(request: nil, response: response, data: nil, error: nil)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let node = result else {
            XCTFail("node is nil")
            return
        }

        XCTAssert(node.kind == XMLRPCNodeKind.methodResponse)
    }

    func testParams() {
        var result: XMLRPCNode?

        do {
            result = try serialize("testParams")
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let node = result else {
            XCTFail("node is nil")
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
        var result: XMLRPCNode?

        do {
            result = try serialize("testStructParam")
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let node = result else {
            XCTFail("node is nil")
            return
        }

        XCTAssertNil(node.error)
        XCTAssertNil(node[0].dictionary)
        XCTAssertNotNil(node[1].dictionary)

        let structNode = node[1]

        XCTAssertEqual(structNode["name"].string, "John Doe")
        XCTAssertEqual(structNode["age"].int32, 32)
        XCTAssertNil(structNode["notExist"].string)
        XCTAssertNotNil(structNode[0].error)
    }

    func testArrayParam() {
        var result: XMLRPCNode?

        do {
            result = try serialize("testArrayParam")
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let node = result else {
            XCTFail("node is nil")
            return
        }

        XCTAssertNil(node.error)
        XCTAssertNil(node[0].array)
        XCTAssertNotNil(node[1].array)
        XCTAssertEqual(node[1].count, 2)

        let arrayNode = node[1]

        XCTAssertEqual(arrayNode[0].int32, 42)
        XCTAssertEqual(arrayNode[1].double, 1.61)
        XCTAssertNotNil(arrayNode["aKey"].error)

        var counter = 0
        for _ in node {
            counter += 1
        }

        XCTAssertEqual(counter, 2)
    }

    func testFault() {
        do {
            _ = try serialize("testFault")
        } catch XMLRPCError.fault(let node) {
            XCTAssertEqual(node.string, "No such method!")
            return
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
    }

    func testFaultStruct() {
        do {
            _ = try serialize("testFaultStruct")
        } catch XMLRPCError.fault(let node) {
            XCTAssertEqual(node["faultCode"].int32, 26)
            XCTAssertEqual(node["faultString"].string, "No such method!")
            return
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
    }

    func testXMLRPCInitializable() {
        struct Person: XMLRPCInitializable {
            let name: String
            let age: Int

            init?(xmlRpcNode node: XMLRPCNode) {
                guard let name = node["name"].string, let age = node["age"].int32 else {
                    return nil
                }

                self.name = name
                self.age = Int(age)
            }
        }

        var result: XMLRPCNode?

        do {
            result = try serialize("testStructParam")
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let node = result else {
            XCTFail("node is nil")
            return
        }

        guard let person: Person = node[1].value() else {
            XCTFail("person is nil")
            return
        }

        XCTAssertEqual(person.name, "John Doe")
        XCTAssertEqual(person.age, 32)

        let person2: Person? = node[0].value()

        XCTAssertNil(person2)
    }
}
