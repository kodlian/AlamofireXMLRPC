//
//  XML.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 08/10/2015.
//  Copyright © 2015 kodlian. All rights reserved.
//

import Foundation
import AEXML

enum XMLRPCNodeKind: String {
    case MethodCall = "methodCall"
    case MethodName = "methodName"
    case MethodResponse = "methodResponse"
    case Fault = "fault"
    
    case i4 = "i4"
    
    case Structure = "struct"
    case Member = "member"
    
    case Parameters = "params"
    case Parameter = "param"
    
    case Array = "array"
    case Data = "data"
    
    case Value = "value"
    case Name = "name"
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
    var rpcValueKind: XMLRPCValueKind? { return XMLRPCValueKind(rawValue: name) }
    
    convenience init(_  rpcValue: XMLRPCValueConvertible) {
        self.init()
        name = rpcValue.xmlRpcKind.rawValue
        value = rpcValue.xmlRpcValue
    }
    
    func addChild(rpcValue rpcValue: XMLRPCValueConvertible) -> AEXMLElement {
        return addChild(name: rpcValue.xmlRpcKind.rawValue, value: rpcValue.xmlRpcValue)
    }
}
struct UnknownRPCValue: XMLRPCValueConvertible {
    var xmlRpcKind: XMLRPCValueKind { return .String }
    private(set) var xmlRpcValue: String
    
    init(_ value: Any) {
        xmlRpcValue = String(value)
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
        case let v as XMLRPCValueConvertible:
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
        
        for (key,value) in rpcStructure {
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

// MARK: - Browse
public struct XMLRPCNode {
    
    static var errorNode = XMLRPCNode(xml: AEXMLElement())
    
    var xml: AEXMLElement

    init(var xml: AEXMLElement) {
        while (xml.rpcNode == .Value || xml.rpcNode == .Parameter) &&  xml.children.count > 0 {
            if let child = xml.children.first {
                xml = child
            }
        }
        self.xml = xml
    }

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
    
    public var string: String? {
        guard xml.rpcValueKind == XMLRPCValueKind.String || (xml.rpcNode == .Value && xml.children.count == 0) else {
            return nil
        }
        
        return xml.value
    }
    
    public var int32: Int32? {
        guard xml.rpcValueKind == XMLRPCValueKind.Integer || xml.rpcNode == XMLRPCNodeKind.i4 else {
            return nil
        }
        guard let v = xml.value else {
            return nil
        }
        
        return Int32(v)
    }
    
    public var double: Double? {
        guard xml.rpcValueKind == XMLRPCValueKind.Double else {
            return nil
        }
        guard let v = xml.value else {
            return nil
        }
        
        return Double(v)
    }
    
    public var bool: Bool? {
        guard xml.rpcValueKind == XMLRPCValueKind.Boolean else {
            return nil
        }
        guard let v = xml.value else {
            return nil
        }
        
        return Int32(v) == 1
    }
    
    public var data: NSData? {
        guard xml.rpcValueKind == XMLRPCValueKind.Base64 else {
            return nil
        }
        guard let v = xml.value else {
            return nil
        }
        
        return NSData(base64EncodedString: v, options: .IgnoreUnknownCharacters)
    }
    
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

// MARK: - Document Call
class XMLRPCCallDocument: AEXMLDocument {
    init(methodName: String, parameters someParams: [Any]?) {
        // Build XMLRPC Call
        super.init(version: 1.0)
        let xmlMethodCall = addChild(rpcNode: .MethodCall)
        xmlMethodCall.addChild(rpcNode: .MethodName, value:methodName)
        if let params = someParams {
            xmlMethodCall.addChild(AEXMLElement(rpcParams: params))
        }
    }
}

