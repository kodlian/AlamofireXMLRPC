//
//  XMLRPCNodeTests.swift
//  AlamofireXMLRPCTests
//
//  Created by Jonathan Foster on 04/06/2021.
//  Copyright © 2016 kodlian. All rights reserved.
//

import XCTest
import AEXML
@testable import AlamofireXMLRPC

class XMLRPCNodeTests: XCTestCase {
    func testInt() {
        let element = AEXMLElement(rpcNode: XMLRPCNodeKind.parameter)
        element.addChild(rpcValue: 1)
        let node = XMLRPCNode(xml: element)

        XCTAssert(node.int == 1)
    }

    func testKind() {
        let element = AEXMLElement(rpcNode: XMLRPCNodeKind.methodResponse)
        let node = XMLRPCNode(xml: element)

        XCTAssert(node.kind == XMLRPCNodeKind.methodResponse)
    }
}
