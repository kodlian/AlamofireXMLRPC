//
//  XML.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 08/10/2015.
//  Copyright © 2015 kodlian. All rights reserved.
//

import Foundation
import AEXML

public enum XMLRPCNodeKind: String {
    case methodCall = "methodCall"
    case methodName = "methodName"
    case methodResponse = "methodResponse"
    case fault = "fault"
    case structure = "struct"
    case member = "member"

    case parameters = "params"
    case parameter = "param"

    case array = "array"
    case data = "data"

    case value = "value"
    case name = "name"
}

extension XMLRPCValueKind {
    init?(xml: AEXMLElement) {

        if let kind = XMLRPCValueKind(rawValue: xml.name) {
            self = kind
        } else {
            switch (xml.name, xml.children.count) {
            case (XMLRPCNodeKind.value.rawValue, 0):
                self = .String

            case ("i4",_):
                self = .Integer

            default:
                return nil
            }
        }

    }
}


// MARK: RPC Node
extension AEXMLElement {
    var rpcNode: XMLRPCNodeKind? { return XMLRPCNodeKind(rawValue: name) }

    convenience init(rpcNode: XMLRPCNodeKind) {
        self.init(name: rpcNode.rawValue)
    }

    @discardableResult func addChild(rpcNode: XMLRPCNodeKind, value: String? = nil) -> AEXMLElement {
        return addChild(name: rpcNode.rawValue, value: value)
    }

    subscript(key: XMLRPCNodeKind) -> AEXMLElement {
        return self[key.rawValue]
    }
}

// MARK: - Value
extension AEXMLElement {
 //   var rpcValueKind: XMLRPCValueKind? { return XMLRPCValueKind(rawValue: name) }

    convenience init(_  rpcValue: XMLRPCRawValueRepresentable) {
        self.init(name: type(of: rpcValue).xmlRpcKind.rawValue)
        name = type(of: rpcValue).xmlRpcKind.rawValue
        value = rpcValue.xmlRpcRawValue
    }

    @discardableResult func addChild(rpcValue: XMLRPCRawValueRepresentable) -> AEXMLElement {
        return addChild(name: type(of: rpcValue).xmlRpcKind.rawValue, value: rpcValue.xmlRpcRawValue)
    }
}

struct UnknownRPCValue: XMLRPCRawValueRepresentable {
    static var xmlRpcKind: XMLRPCValueKind { return .String }
    fileprivate(set) var xmlRpcRawValue: String

    init(_ value: Any) {
        xmlRpcRawValue = String(describing: value)
    }
}

// MARK: - Collectiom
extension AEXMLElement {
    fileprivate func addRPCValue(_ value: Any) {
        let xmlValue = addChild(rpcNode:XMLRPCNodeKind.value)
        switch value {
        case let v as XMLRPCRawValueRepresentable:
            xmlValue.addChild(rpcValue:v)
        case let array as [Any]:
            xmlValue.addChild(AEXMLElement(rpcArray: array))
        case let dict as [String:Any]:
            xmlValue.addChild(AEXMLElement(rpcStructure: dict))
        default:
            xmlValue.addChild(rpcValue:UnknownRPCValue(value))
        }
    }

    convenience init(rpcArray: [Any]) {
        self.init(rpcNode: XMLRPCNodeKind.array)

        let xmlElement = addChild(rpcNode: XMLRPCNodeKind.data)
        for element in rpcArray {
            xmlElement.addRPCValue(element)
        }
    }
    convenience init(rpcParams: [Any]) {
        self.init(rpcNode: XMLRPCNodeKind.parameters)

        for item in rpcParams {
            addChild(rpcNode: .parameter).addRPCValue(item)
        }
    }

    convenience init(rpcStructure: [String:Any]) {
        self.init(rpcNode: XMLRPCNodeKind.structure)

        for (key, value) in rpcStructure {
            let member = addChild(rpcNode: XMLRPCNodeKind.member)
            member.addChild(rpcNode: XMLRPCNodeKind.name, value: key)
            member.addRPCValue(value)
        }
    }

    var rpcChildren: [AEXMLElement]? {
        guard rpcNode == XMLRPCNodeKind.array || rpcNode == XMLRPCNodeKind.parameters else {
            return nil
        }

        return rpcNode == XMLRPCNodeKind.array ? self[.data].children : children
    }


}
