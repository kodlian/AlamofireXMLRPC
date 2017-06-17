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
        let xml = AEXMLElement(name: "")
        xml.error = .elementNotFound
        return XMLRPCNode(xml: xml)
    }()

    var xml: AEXMLElement

    init( xml rootXML: AEXMLElement) {
        var xml = rootXML
        while (xml.rpcNode == .value || xml.rpcNode == .parameter) &&  xml.children.count > 0 {
            if let child = xml.children.first {
                xml = child
            }
        }
        self.xml = xml
    }
}

// MARK: - Array
extension XMLRPCNode: Collection {
    public func index(after i: Int) -> Int {
        return xml.rpcChildren?.index(after: i) ?? 0
    }

    public var array: [XMLRPCNode]? {
        if let children = xml.rpcChildren {
            return children.map { e in
                if let value = e.children.first {
                    return XMLRPCNode(xml: value)
                }
                return type(of: self).errorNode
            }
        }

        return nil
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return xml.rpcChildren?.count ?? 0
    }

    public subscript(key: Int) -> XMLRPCNode {
        guard let children = xml.rpcChildren , (key >= 0 && key < children.count) else {
            return type(of: self).errorNode
        }

        return XMLRPCNode(xml: children[key])
    }
}


// MARK: - Struct
extension XMLRPCNode {
    public subscript(key: String) -> XMLRPCNode {
        guard xml.rpcNode == XMLRPCNodeKind.structure else {
            return type(of: self).errorNode
        }
        for child in xml.children {
            if child[XMLRPCNodeKind.name].value == key {
                return XMLRPCNode(xml: child[XMLRPCNodeKind.value])
            }
        }

        return type(of: self).errorNode
    }

    public var dictionary: [String:XMLRPCNode]? {
        guard xml.rpcNode == XMLRPCNodeKind.structure else {
            return nil
        }

        var dictionary = [String:XMLRPCNode]()

        for child in xml.children {
            if let key = child[XMLRPCNodeKind.name].value {
                dictionary[key] = XMLRPCNode(xml: child[XMLRPCNodeKind.value])
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
        guard let value = xml.value, let nodeKind = XMLRPCValueKind(xml: xml) , nodeKind == V.xmlRpcKind else {
            return nil
        }

        return V(xmlRpcRawValue: value)
    }

    public var date: Date? { return value() }

    public var data: Data? { return value() }

    public var error: AEXML.AEXMLError? {
        return xml.error
    }
}

extension XMLRPCNode: CustomStringConvertible {
    public var description: String {
        return xml.value ?? ""
    }
}

// MARK: - Object Value
public protocol XMLRPCInitializable  {
    init?(xmlRpcNode: XMLRPCNode)
}

extension XMLRPCNode {
    public func value<V: XMLRPCInitializable>() -> V? {
        if self.error != nil {
            return nil
        }
        
        return V(xmlRpcNode: self)
    }
}




