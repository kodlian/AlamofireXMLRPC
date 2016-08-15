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
    case MethodCall = "methodCall"
    case MethodName = "methodName"
    case MethodResponse = "methodResponse"
    case Fault = "fault"
    case Structure = "struct"
    case Member = "member"

    case Parameters = "params"
    case Parameter = "param"

    case Array = "array"
    case Data = "data"

    case Value = "value"
    case Name = "name"
}

extension XMLRPCValueKind {
    init?(xml: AEXMLElement) {

        if let kind = XMLRPCValueKind(rawValue: xml.name) {
            self = kind
        } else {
            switch (xml.name, xml.count) {
            case (XMLRPCNodeKind.Value.rawValue, 0):
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
        self.init()
        name = rpcNode.rawValue
    }

    func addChild(rpcNode rpcNode: XMLRPCNodeKind, value: String? = nil) -> AEXMLElement {
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
        self.init()
        name = rpcValue.dynamicType.xmlrpcKind.rawValue
        value = rpcValue.xmlrpcRawValue
    }

    func addChild(rpcValue rpcValue: XMLRPCRawValueRepresentable) -> AEXMLElement {
        return addChild(name: rpcValue.dynamicType.xmlrpcKind.rawValue, value: rpcValue.xmlrpcRawValue)
    }
}

struct UnknownRPCValue: XMLRPCRawValueRepresentable {
    static var xmlrpcKind: XMLRPCValueKind { return .String }
    private(set) var xmlrpcRawValue: String

    init(_ value: Any) {
        xmlrpcRawValue = String(value)
    }
}

// MARK: - Collectiom
protocol XMLRPCArrayType { }
extension Array: XMLRPCArrayType { }

protocol XMLRPCStructureType { }
extension Dictionary: XMLRPCStructureType { }


extension AEXMLElement {
    private func addRPCValue(value: Any) {
        let xmlValue = addChild(rpcNode:XMLRPCNodeKind.Value)
        switch value {
        case let v as XMLRPCRawValueRepresentable:
            xmlValue.addChild(rpcValue:v)
        case is XMLRPCArrayType:
            if let array = value as? [Any] {
                xmlValue.addChild(AEXMLElement(rpcArray: array))
            }
        case is XMLRPCStructureType:
            guard let dict = value as? [String:Any] else {
                fallthrough
            }
            xmlValue.addChild(AEXMLElement(rpcStructure: dict))
        default:
            xmlValue.addChild(rpcValue:UnknownRPCValue(value))
        }
    }

    convenience init(rpcArray: [Any]) {
        self.init(rpcNode: XMLRPCNodeKind.Array)

        let xmlElement = addChild(rpcNode: XMLRPCNodeKind.Data)
        for element in rpcArray {
            xmlElement.addRPCValue(element)
        }
    }
    convenience init(rpcParams: [Any]) {
        self.init(rpcNode: XMLRPCNodeKind.Parameters)

        for item in rpcParams {
            addChild(rpcNode: .Parameter).addRPCValue(item)
        }
    }

    convenience init(rpcStructure: [String:Any]) {
        self.init(rpcNode: XMLRPCNodeKind.Structure)

        for (key, value) in rpcStructure {
            let member = addChild(rpcNode: XMLRPCNodeKind.Member)
            member.addChild(rpcNode: XMLRPCNodeKind.Name, value: key)
            member.addRPCValue(value)
        }
    }

    var rpcChildren: [AEXMLElement]? {
        guard rpcNode == XMLRPCNodeKind.Array || rpcNode == XMLRPCNodeKind.Parameters else {
            return nil
        }

        return rpcNode == XMLRPCNodeKind.Array ? self[.Data].children : children
    }


}
