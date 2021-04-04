//
//  Alanofire+XML.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 08/10/2015.
//  Copyright © 2015 kodlian. All rights reserved.
//

import Foundation
import AEXML
import Alamofire

extension DataRequest {
    @discardableResult public func responseXML(
        queue: DispatchQueue = .main,
        dataPreprocessor: DataPreprocessor = XMLResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = XMLResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = XMLResponseSerializer.defaultEmptyRequestMethods,
        completionHandler: @escaping (AFDataResponse<AEXMLDocument>) -> Void
    ) -> Self {
        response(
            queue: queue,
            responseSerializer: XMLResponseSerializer(
                dataPreprocessor: dataPreprocessor,
                emptyResponseCodes: emptyResponseCodes,
                emptyRequestMethods: emptyRequestMethods
            ),
            completionHandler: completionHandler)
    }
}

public class XMLResponseSerializer: ResponseSerializer {
    public let dataPreprocessor: DataPreprocessor
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>

    public init(
        dataPreprocessor: DataPreprocessor = XMLResponseSerializer.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = XMLResponseSerializer.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = XMLResponseSerializer.defaultEmptyRequestMethods
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
    ) throws -> AEXMLDocument {
        guard error == nil else { throw error! }

        guard var data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }

            let errorDocument = AEXMLDocument()
            errorDocument.error = .parsingFailed
            return errorDocument
        }

        data = try dataPreprocessor.preprocess(data)

        do {
            return try AEXMLDocument(xml: data)
        } catch {
            throw XMLRPCError.responseSerializationFailed(reason: .xmlSerializationFailed(error: error))
        }
    }
}
