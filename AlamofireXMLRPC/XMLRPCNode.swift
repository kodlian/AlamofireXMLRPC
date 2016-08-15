//
//  XMLRPCNode.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 15/08/2016.
//  Copyright © 2016 kodlian. All rights reserved.
//

import Foundation
import AEXML

// MARK: - XMLRPCNode
public struct XMLRPCNode {
    static var errorNode: XMLRPCNode = {
        let xml = AEXMLElement()
        xml.error = .ElementNotFound
        return XMLRPCNode(xml: xml)
    }()

    var xml: AEXMLElement

    init( xml rootXML: AEXMLElement) {
        var xml = rootXML
        while (xml.rpcNode == .Value || xml.rpcNode == .Parameter) &&  xml.children.count > 0 {
            if let child = xml.children.first {
                xml = child
            }
        }
        self.xml = xml
    }
}

// MARK: - Array
// TODO: Implement collection type
extension XMLRPCNode {
    public var array: [XMLRPCNode]? {
        if let children = xml.rpcChildren {
            return children.map { e in
                if let value = e.children.first {
                    return XMLRPCNode(xml: value)
                }
                return self.dynamicType.errorNode
            }
        }

        return nil
    }

    public var count: Int? {
        return xml.rpcChildren?.count
    }

    public subscript(key: Int) -> XMLRPCNode {
        guard let children = xml.rpcChildren where (key >= 0 && key < children.count) else {
            return self.dynamicType.errorNode
        }

        return XMLRPCNode(xml: children[key])
    }
}


// MARK: - Struct
extension XMLRPCNode {
    public subscript(key: String) -> XMLRPCNode {
        guard xml.rpcNode == XMLRPCNodeKind.Structure else {
            return self.dynamicType.errorNode
        }
        for child in xml.children {
            if child[XMLRPCNodeKind.Name].value == key {
                return XMLRPCNode(xml: child[XMLRPCNodeKind.Value])
            }
        }

        return self.dynamicType.errorNode
    }

    public var dictionary: [String:XMLRPCNode]? {
        guard xml.rpcNode == XMLRPCNodeKind.Structure else {
            return nil
        }

        var dictionary = [String:XMLRPCNode]()

        for child in xml.children {
            if let key = child[XMLRPCNodeKind.Name].value {
                dictionary[key] = XMLRPCNode(xml: child[XMLRPCNodeKind.Value])
            }
        }

        return dictionary
    }
}

// MARK: - Value
extension XMLRPCNode {
    public var string: String? { return value() }

    public var int32: Int32? { return value() }

    public var double: Double? { return value() }

    public var bool: Bool? { return value() }

    public func value<V: XMLRPCRawValueRepresentable>() -> V? {
        guard let value = xml.value, nodeKind = XMLRPCValueKind(xml: xml) where nodeKind == V.xmlrpcKind else {
            return nil
        }

        return V(xmlrpcRawValue: value)
    }

    public var date: NSDate? {
        guard let rawData = xml.value, nodeKind = XMLRPCValueKind(xml: xml) where nodeKind == XMLRPCValueKind.DateTime else {
            return nil
        }
        // TODO: Move Code - We able to Implement intializer init?(xmlrpcRawValue: String)  in swift 3 in NSDate extension
        return iso8601DateFormatter.dateFromString(rawData)
    }

    public var data: NSData? {
        guard let rawData = xml.value, nodeKind = XMLRPCValueKind(xml: xml) where nodeKind == XMLRPCValueKind.Base64 else {
            return nil
        }
        // TODO: Move Code - We able to Implement intializer init?(xmlrpcRawValue: String)  in swift 3 in NSData extension
        return NSData(base64EncodedString: rawData, options: .IgnoreUnknownCharacters)
    }

    public var error: AEXMLElement.Error? {
        return xml.error
    }
}
