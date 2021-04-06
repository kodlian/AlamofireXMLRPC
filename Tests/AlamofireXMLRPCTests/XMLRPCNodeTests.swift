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
    func testKind() {
        let methodResponseElement = AEXMLElement(rpcNode: XMLRPCNodeKind.methodResponse)
        let methodResponseNode = XMLRPCNode(xml: methodResponseElement)

        XCTAssert(methodResponseNode.kind == XMLRPCNodeKind.methodResponse)
    }
}
