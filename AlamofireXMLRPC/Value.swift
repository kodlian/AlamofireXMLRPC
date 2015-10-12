//
//  Type.swift
//  AlamofireXMLRPC
//
//  Created by Jeremy Marchand on 08/10/2015.
//  Copyright © 2015 kodlian. All rights reserved.
//

import Foundation

public enum XMLRPCValueKind: String {
    case Integer = "int"
    case Double = "double"
    case Boolean = "boolean"
    case String = "string"
    case DateTime = "dateTime.iso8601"
    case Base64 = "base64"
}

public protocol XMLRPCValueConvertible {
    var xmlRpcKind: XMLRPCValueKind { get }
    var xmlRpcValue: String { get }
}

public extension XMLRPCValueConvertible {
    var xmlRpcKind: XMLRPCValueKind { return .String }
    var xmlRpcValue: String { return String(self) }
}

extension String: XMLRPCValueConvertible {
    public var xmlRpcKind: XMLRPCValueKind { return .String }
    public var xmlRpcValue: String { return self }
}

extension Bool: XMLRPCValueConvertible {
    public var xmlRpcKind: XMLRPCValueKind { return .Boolean }
}

extension XMLRPCValueConvertible where Self: IntegerType {
    public var xmlRpcKind: XMLRPCValueKind { return .Integer }
}
extension Int: XMLRPCValueConvertible {
    public var xmlRpcValue: String { return String(Int32(self))} // Truncate Int
}
extension Int32: XMLRPCValueConvertible { }
extension Int16: XMLRPCValueConvertible { }
extension Int8: XMLRPCValueConvertible { }
extension UInt16: XMLRPCValueConvertible { }
extension UInt8: XMLRPCValueConvertible { }

public extension XMLRPCValueConvertible where Self: FloatingPointType  {
    public var xmlRpcKind: XMLRPCValueKind { return .Double }
}
extension Double: XMLRPCValueConvertible { }
extension Float: XMLRPCValueConvertible { }

var ISO8601DateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
    dateFormatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
    return dateFormatter
    }()

extension NSDate {
    var ISO8601String: String {
        return ISO8601DateFormatter.stringFromDate(self)
    }
}
extension NSDate: XMLRPCValueConvertible {
    public var xmlRpcKind: XMLRPCValueKind { return .DateTime }
    public var xmlRpcValue: String {
        return self.ISO8601String
    }
}

extension NSData: XMLRPCValueConvertible {
    public var xmlRpcKind: XMLRPCValueKind { return .Base64 }
    public var xmlRpcValue: String {
        return self.base64EncodedStringWithOptions([])
    }
}

public typealias XMLRPCStructure = [String:Any]
public typealias XMLRPCArray = [Any]
