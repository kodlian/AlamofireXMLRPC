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

// MARK: - Document Call
class XMLRPCCallDocument: AEXMLDocument {
    init(methodName: String, parameters someParams: [Any]?) {
        // Build XMLRPC Call
        super.init()
        let xmlMethodCall = addChild(rpcNode: .methodCall)
        xmlMethodCall.addChild(rpcNode: .methodName, value:methodName)
        if let params = someParams {
            xmlMethodCall.addChild(AEXMLElement(rpcParams: params))
        }
    }
}

// MARK: -
extension SessionManager {
    public func requestXMLRPC(_ url: URLConvertible, methodName: String, parameters: [Any]?, headers: [String : String]? = nil) -> DataRequest {

        let request = XMLRPCRequest(url: url, methodName: methodName, parameters: parameters, headers: headers)
        let dataRequest = self.request(request)
        return dataRequest
    }
}

public func request(_ url: URLConvertible, methodName: String, parameters: [Any]?, headers: [String : String]? = nil) -> DataRequest {
    return SessionManager.default.requestXMLRPC(
        url, methodName: methodName, parameters: parameters, headers: headers
    )
}

public func request(_ XMLRPCRequest: XMLRPCRequestConvertible) -> DataRequest {
    return SessionManager.default.request(XMLRPCRequest)
}

// MARK: - RequestConvertible
public protocol XMLRPCRequestConvertible: URLRequestConvertible {
    var url: URLConvertible { get }
    var methodName: String { get }
    var parameters: [Any]? { get }
    var headers: [String : String]? { get }
}

extension XMLRPCRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = try self.url.asURL()
      
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        if let h = headers {
            for (key, value) in h {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let xmlData = XMLRPCCallDocument(methodName: methodName, parameters: parameters).xml.data(using: String.Encoding.utf8) else {
            throw XMLRPCError.parseFailed
        }
        request.httpBody = xmlData
        
        return request
    }
}

fileprivate struct XMLRPCRequest: XMLRPCRequestConvertible {
    var url: URLConvertible
    var methodName: String
    var parameters: [Any]?
    var headers: [String : String]?
}

// MARK: - Response
extension DataRequest {
    public static func XMLRPCResponseSerializer() -> DataResponseSerializer<XMLRPCNode> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(XMLRPCError.networkError(error))
            }

            let result = XMLResponseSerializer().serializeResponse(request, response, data, error)

            guard let xml = result.value , result.isSuccess else {
                return .failure(XMLRPCError.xmlSerializationFailed)
            }

            let xmlResponse = xml[.methodResponse]
            guard xmlResponse.error == nil else {
                return .failure(XMLRPCError.nodeNotFound(node: .methodResponse))
            }

            let fault = xmlResponse[.fault]
            guard fault.error != nil else {
                return .failure(XMLRPCError.fault(node: XMLRPCNode(xml: fault[.value])))
            }

            let params = xmlResponse[.parameters]
            if params.rpcNode == .parameters {
                return .success(XMLRPCNode(xml:params))
            } else {
                return .failure(XMLRPCError.nodeNotFound(node: .parameters))
            }
        }
    }

    @discardableResult public func responseXMLRPC(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<XMLRPCNode>) -> Void) -> Self {

        return response(queue:queue, responseSerializer: DataRequest.XMLRPCResponseSerializer(), completionHandler: completionHandler)
    }
}
