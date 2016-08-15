//
//  XMLRPCError.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import Foundation

public enum XMLRPCError: ErrorType {
    case NetworkError(NSError?)
    case XMLSerializationFailed
    case NodeNotFound(node: XMLRPCNodeKind)
    case Fault(node: XMLRPCNode)
}
