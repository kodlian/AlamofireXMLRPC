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
        xmlMethodCall.addChild(rpcNode: .methodName, value: methodName)
        if let params = someParams {
            xmlMethodCall.addChild(AEXMLElement(rpcParams: params))
        }
    }
}

// MARK: - Session
extension Session {
    public func requestXMLRPC(
        _ url: URLConvertible,
        methodName: String,
        parameters: [Any]?,
        headers: [String: String]? = nil
    ) -> DataRequest {
        let request = XMLRPCRequest(url: url, methodName: methodName, parameters: parameters, headers: headers)
        let dataRequest = self.request(request)
        return dataRequest
    }
}

public func request(
    _ url: URLConvertible,
    methodName: String,
    parameters: [Any]?,
    headers: [String: String]? = nil
) -> DataRequest {
    return Session.default.requestXMLRPC(
        url, methodName: methodName, parameters: parameters, headers: headers
    )
}

public func request(_ XMLRPCRequest: XMLRPCRequestConvertible) -> DataRequest {
    return Session.default.request(XMLRPCRequest)
}

// MARK: - RequestConvertible
public protocol XMLRPCRequestConvertible: URLRequestConvertible {
    var url: URLConvertible { get }
    var methodName: String { get }
    var parameters: [Any]? { get }
    var headers: [String: String]? { get }
}

extension XMLRPCRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = try self.url.asURL()

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        if let headers = self.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let xmlData = XMLRPCCallDocument(
                methodName: methodName,
                parameters: parameters).xml.data(using: String.Encoding.utf8)
        else {
            throw XMLRPCError.parseFailed
        }
        request.httpBody = xmlData

        return request
    }
}

private struct XMLRPCRequest: XMLRPCRequestConvertible {
    var url: URLConvertible
    var methodName: String
    var parameters: [Any]?
    var headers: [String: String]?
}

// MARK: - Response
extension DataRequest {
    @discardableResult public func responseXMLRPC(
        queue: DispatchQueue = .main,
        dataPreprocessor: DataPreprocessor = XMLRPCResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = XMLRPCResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = XMLRPCResponseSerializer.defaultEmptyRequestMethods,
        completionHandler: @escaping (AFDataResponse<XMLRPCNode>) -> Void
    ) -> Self {
        response(
            queue: queue,
            responseSerializer: XMLRPCResponseSerializer(
                dataPreprocessor: dataPreprocessor,
                emptyResponseCodes: emptyResponseCodes,
                emptyRequestMethods: emptyRequestMethods
            ),
            completionHandler: completionHandler)
    }
}

public class XMLRPCResponseSerializer: ResponseSerializer {
    public let dataPreprocessor: DataPreprocessor
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>

    public init(
        dataPreprocessor: DataPreprocessor = XMLRPCResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = XMLRPCResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = XMLRPCResponseSerializer.defaultEmptyRequestMethods
    ) {
        self.dataPreprocessor = dataPreprocessor
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
    }

    public func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> XMLRPCNode {
        guard error == nil else { throw error! }

        guard var data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw XMLRPCError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }

            let errorElement = AEXMLElement(name: "Error")
            errorElement.error = .parsingFailed
            return XMLRPCNode(xml: errorElement)
        }

        data = try dataPreprocessor.preprocess(data)

        let xmlDocument = try AEXMLDocument(xml: data)
        if let error = xmlDocument.error {
            throw XMLRPCError.responseSerializationFailed(reason: .xmlSerializationFailed(error: error))
        }

        let methodResponse = xmlDocument[.methodResponse]
        guard methodResponse.error == nil else {
            throw XMLRPCError.responseSerializationFailed(reason: .nodeNotFound(node: .methodResponse))
        }

        let fault = methodResponse[.fault]
        if fault.error == nil {
            throw XMLRPCError.fault(node: XMLRPCNode(xml: fault[.value]))
        }

        let params = methodResponse[.parameters]
        if params.error == nil {
            return XMLRPCNode(xml: params)
        }

        throw XMLRPCError.responseSerializationFailed(reason: .nodeNotFound(node: .parameters))
    }
}
