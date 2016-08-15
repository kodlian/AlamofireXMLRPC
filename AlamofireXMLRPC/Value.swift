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

public protocol XMLRPCRawValueRepresentable {
    static var xmlrpcKind: XMLRPCValueKind { get }
    var xmlrpcRawValue: String { get }
    init?(xmlrpcRawValue: String)
}


public extension XMLRPCRawValueRepresentable {
    static var xmlrpcKind: XMLRPCValueKind { return .String }
    var xmlrpcRawValue: String { return String(self) }
    init?(xmlrpcRawValue: String) {
        return nil
    }
}

public extension RawRepresentable where RawValue == String, Self: XMLRPCRawValueRepresentable {
    init?(xmlrpcRawValue: String) {
        self.init(rawValue: xmlrpcRawValue)
    }
    var xmlrpcRawValue: String { return rawValue }
}

// MARK: String
extension String: XMLRPCRawValueRepresentable {
    public static var xmlrpcKind: XMLRPCValueKind { return .String }
    public var xmlrpcRawValue: String { return self }
    public init?(xmlrpcRawValue: String) {
        self = xmlrpcRawValue
    }
}

// MARK: Bool
extension Bool: XMLRPCRawValueRepresentable {
    public static var xmlrpcKind: XMLRPCValueKind { return .Boolean }
    public init?(xmlrpcRawValue: String) {
        self = Int8(xmlrpcRawValue) == 1
    }
}

// MARK: Integer
extension XMLRPCRawValueRepresentable where Self: IntegerType {
    public static var xmlrpcKind: XMLRPCValueKind { return .Integer }
}

public protocol StringRadixParsable {
    init?(_ text: String, radix: Int)
}

extension XMLRPCRawValueRepresentable where Self: StringRadixParsable {
    public init?(xmlrpcRawValue: String) {
        self.init(xmlrpcRawValue, radix: 10)
    }
}

extension Int: StringRadixParsable { }
extension Int32: StringRadixParsable { }
extension Int8: StringRadixParsable { }
extension UInt16: StringRadixParsable { }
extension UInt8: StringRadixParsable { }


extension Int: XMLRPCRawValueRepresentable {
    public var xmlrpcRawValue: String { return String(Int32(self))} // Truncate Int
}
extension Int32: XMLRPCRawValueRepresentable { }
extension Int16: XMLRPCRawValueRepresentable { }
extension Int8: XMLRPCRawValueRepresentable { }
extension UInt16: XMLRPCRawValueRepresentable { }
extension UInt8: XMLRPCRawValueRepresentable { }


// MARK: Floating Point
public extension XMLRPCRawValueRepresentable where Self: FloatingPointType {
    public static var xmlrpcKind: XMLRPCValueKind { return .Double }
}

extension Double: XMLRPCRawValueRepresentable {
    public init?(xmlrpcRawValue: String) {
        self.init(xmlrpcRawValue)
    }
}
extension Float: XMLRPCRawValueRepresentable {
    public init?(xmlrpcRawValue: String) {
      self.init(xmlrpcRawValue)
    }
}


// MARK: Date
let iso8601DateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
        return dateFormatter
}()

extension NSDate {
    var iso8601String: String {
        return iso8601DateFormatter.stringFromDate(self)
    }
}
extension NSDate: XMLRPCRawValueRepresentable {
    public static var xmlrpcKind: XMLRPCValueKind { return .DateTime }
    public var xmlrpcRawValue: String {
        return self.iso8601String
    }
}

// MARK: Data
extension NSData: XMLRPCRawValueRepresentable {
    public static var xmlrpcKind: XMLRPCValueKind { return .Base64 }
    public var xmlrpcRawValue: String {
        return self.base64EncodedStringWithOptions([])
    }
}

public typealias XMLRPCStructure = [String:Any]
public typealias XMLRPCArray = [Any]
