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
    public static func XMLResponseSerializer() -> DataResponseSerializer<AEXMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            if let e = error {
                return .failure(e)
            }

            guard let validData = data else {
                return .failure(AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.dataFileNil))
            }

            do {
                // Filter control characters
                if var text = String(data: validData, encoding: .utf8) {
                    // control character excludes \n \t \r
                    let sets = CharacterSet.controlCharacters.subtracting(CharacterSet(charactersIn: "\n\t\r"))
                    text = text.components(separatedBy: sets).joined()
                    let XML = try AEXMLDocument(xml: text)
                    return .success(XML)
                } else {
                    let XML = try AEXMLDocument(xml: validData)
                    return .success(XML)
                }
            } catch {
                return .failure(error)
            }
        }
    }

    public func responseXMLDocument(queue: DispatchQueue? = nil,  completionHandler: @escaping (DataResponse<AEXMLDocument>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.XMLResponseSerializer(), completionHandler: completionHandler)
    }
}


