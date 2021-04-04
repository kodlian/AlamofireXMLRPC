//
//  XMLRPCError.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import Foundation

public enum XMLRPCError: Error {
    public enum ResponseSerializationFailureReason {
        case inputDataNilOrZeroLength
        case nodeNotFound(node: XMLRPCNodeKind)
        case xmlSerializationFailed(error: Error)
    }

    case networkError(Error?)
    case xmlSerializationFailed
    case parseFailed
    case nodeNotFound(node: XMLRPCNodeKind)
    case fault(node: XMLRPCNode)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
}

