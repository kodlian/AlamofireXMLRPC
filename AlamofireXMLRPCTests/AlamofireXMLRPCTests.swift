//
//  AlamofireXMLRPCTests.swift
//  AlamofireXMLRPCTests
//
//  Created by Jeremy Marchand on 09/10/2015.
//  Copyright © 2015 kodlian. All rights reserved.
//

import XCTest
@testable import AlamofireXMLRPC
import AEXML
import Alamofire

class AlamofireXMLRPCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRPCXMLCall() {
        let expt = self.expectationWithDescription("XMLRPCCall")

        let data = "thiswillbencoded".dataUsingEncoding(NSUTF8StringEncoding)!

        let params: [Any] = [42,"string",3.44,NSDate(),data,[1,2,3,5.0,"substring",XMLRPCArray([1])] as XMLRPCArray,["key":"value","keyint":2] as XMLRPCStructure]

        request("http://localhost:8888/xmlrpc", methodName: "testMethod", parameters: params).responseXMLRPC { (response:Response<XMLRPCNode, NSError>) -> Void in
            XCTAssert(response.result.value?.count > 0, "")
            
            expt.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(4, handler: nil)
    }
}
