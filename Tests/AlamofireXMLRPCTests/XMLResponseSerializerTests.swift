//
//  XMLResponseSerializerTests.swift
//  AlamofireXMLRPCTests
//
//  Created by Jonathan Foster on 04/06/2021.
//  Copyright © 2021 kodlian. All rights reserved.
//

import XCTest
import AEXML
import Alamofire
@testable import AlamofireXMLRPC

class XMLResponseSerializerTests: XCTestCase {
    func testEmptyResponse() {
        let serializer = XMLResponseSerializer()
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
        let serializer = XMLResponseSerializer()
        let responseURL = URL(string: "http://localhost")!
        let response = HTTPURLResponse(url: responseURL, statusCode: 204, httpVersion: nil, headerFields: nil)

        var result: AEXMLDocument?

        do {
            result = try serializer.serialize(request: nil, response: response, data: nil, error: nil)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }

        guard let document = result else {
            XCTFail("node is nil")
            return
        }

        XCTAssert(document.root.error == AEXMLError.rootElementMissing)
    }
}
