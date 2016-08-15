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

extension Request {
    public static func XMLResponseSerializer() -> ResponseSerializer<AEXMLDocument, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }

            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."

                let error = NSError(domain: Error.Domain, code: Error.Code.DataSerializationFailed.rawValue, userInfo: [NSLocalizedDescriptionKey : failureReason])
                return .Failure(error)
            }

            do {
                let XML = try AEXMLDocument(xmlData: validData)
                return .Success(XML)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }

    public func responseXMLDocument(completionHandler: Response<AEXMLDocument, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
    }
}
