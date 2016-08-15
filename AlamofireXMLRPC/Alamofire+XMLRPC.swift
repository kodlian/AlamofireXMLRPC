//
//  Alamofire+XMLRPC.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 05/10/15.
//  Copyright © 2015 kodlian. All rights reserved.
//

import Foundation
import Alamofire
import AEXML

// MARK: -
extension Manager {
    public func requestXMLRPC(URLString: URLStringConvertible, methodName: String, parameters: [Any]?, headers: [String : String]? = nil) -> Request {

        guard let xmlData = XMLRPCCallDocument(methodName: methodName, parameters: parameters).xmlString.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("XML generation failed")
        }

        return request(.POST, URLString, parameters: ["XML":xmlData], encoding: .Custom({ (URLRequest: URLRequestConvertible, p: [String : AnyObject]?) -> (NSMutableURLRequest, NSError?) in
            let mutableURLRequest = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
            mutableURLRequest.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = p?["XML"] as? NSData

            return (mutableURLRequest, nil)

        }), headers: headers)
    }
}

public func request(URLString: URLStringConvertible, methodName: String, parameters: [Any]?, headers: [String : String]? = nil) -> Request {
    return Manager.sharedInstance.requestXMLRPC(
        URLString, methodName: methodName, parameters: parameters, headers: headers
    )
}

public func request(XMLRPCRequest: XMLRPCRequestConvertible) -> Request {
    return Manager.sharedInstance.request(XMLRPCRequest)
}

// MARK: - RequestConvertible
public protocol XMLRPCRequestConvertible: URLRequestConvertible {
    var URLString: URLStringConvertible { get }
    var methodName: String { get }
    var parameters: [Any]? { get }
    var headers: [String : String]? { get }
}

//extension XMLRPCRequestConvertible {
//    var parameters: [Any]? { return nil }
//    var headers: [String : String]? { return nil }
//}
public extension URLRequestConvertible where Self:XMLRPCRequestConvertible {
    public var URLRequest: NSMutableURLRequest {

        guard let url = NSURL(string: URLString.URLString) else {
            fatalError("Wrong URL \(URLString)")
        }

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        if let h = headers {
            for (key, value) in h {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let xmlData = XMLRPCCallDocument(methodName: methodName, parameters: parameters).xmlString.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("XML generation failed")
        }
        request.HTTPBody = xmlData

        return request
    }
}

// MARK: - Response
extension Request {
    public static func XMLRPCResponseSerializer() -> ResponseSerializer<XMLRPCNode, XMLRPCError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(.NetworkError(error)) }

            let result = XMLResponseSerializer().serializeResponse(request, response, data, error)

            guard let xml = result.value where result.isSuccess else {
                return .Failure(.XMLSerializationFailed)
            }

            let xmlResponse = xml[.MethodResponse]
            guard xmlResponse.error == nil else {
                return .Failure(.NodeNotFound(node: .MethodResponse))
            }

            let fault = xmlResponse[.Fault]
            guard fault.error != nil else {
                return .Failure(.Fault(node: XMLRPCNode(xml: fault[.Value])))
            }

            let params = xmlResponse[.Parameters]
            if params.rpcNode == .Parameters {
                return .Success(XMLRPCNode(xml:params))
            } else {
                return .Failure(.NodeNotFound(node: .Parameters))
            }


        }
    }

    public func responseXMLRPC(completionHandler: Response<XMLRPCNode, XMLRPCError> -> Void) -> Self {
        return response(responseSerializer: Request.XMLRPCResponseSerializer(), completionHandler: completionHandler)
    }
}
