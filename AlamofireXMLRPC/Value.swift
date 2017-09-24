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
    static var xmlRpcKind: XMLRPCValueKind { get }
    var xmlRpcRawValue: String { get }
    init?(xmlRpcRawValue: String)
}


public extension XMLRPCRawValueRepresentable {
    static var xmlRpcKind: XMLRPCValueKind { return .String }
    var xmlRpcRawValue: String { return String(describing: self) }
    init?(xmlRpcRawValue: String) {
        return nil
    }
}

public extension RawRepresentable where RawValue == String, Self: XMLRPCRawValueRepresentable {
    init?(xmlRpcRawValue: String) {
        self.init(rawValue: xmlRpcRawValue)
    }
    var xmlRpcRawValue: String { return rawValue }
}

// MARK: String
extension String: XMLRPCRawValueRepresentable {
    public static var xmlRpcKind: XMLRPCValueKind { return .String }
    public var xmlRpcRawValue: String { return self }
    public init?(xmlRpcRawValue: String) {
        self = xmlRpcRawValue
    }
}

// MARK: Bool
extension Bool: XMLRPCRawValueRepresentable {
    public static var xmlRpcKind: XMLRPCValueKind { return .Boolean }
    public var xmlRpcRawValue: String { return self ? "1" : "0" }
    public init?(xmlRpcRawValue: String) {
        self.init(Int8(xmlRpcRawValue) == 1)
    }
}

// MARK: Integer
extension XMLRPCRawValueRepresentable where Self: BinaryInteger {
    public static var xmlRpcKind: XMLRPCValueKind { return .Integer }
}

public protocol StringRadixParsable {
    init?(_ text: String, radix: Int)
}

extension XMLRPCRawValueRepresentable where Self: FixedWidthInteger {
    public init?(xmlRpcRawValue: String) {
        self.init(xmlRpcRawValue, radix: 10)
    }
}

extension Int: XMLRPCRawValueRepresentable { }
extension Int32: XMLRPCRawValueRepresentable { }
extension Int16: XMLRPCRawValueRepresentable { }
extension Int8: XMLRPCRawValueRepresentable { }
extension UInt16: XMLRPCRawValueRepresentable { }
extension UInt8: XMLRPCRawValueRepresentable { }

// MARK: Floating Point
public extension XMLRPCRawValueRepresentable where Self: LosslessStringConvertible {
    public init?(xmlRpcRawValue: String) {
        self.init(xmlRpcRawValue)
    }
}

public extension XMLRPCRawValueRepresentable where Self: FloatingPoint {
    public static var xmlRpcKind: XMLRPCValueKind { return .Double }
}

extension Double: XMLRPCRawValueRepresentable { }
extension Float: XMLRPCRawValueRepresentable { }

// MARK: Date
let iso8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
        return dateFormatter
}()

extension Date {
    var iso8601String: String {
        return iso8601DateFormatter.string(from: self)
    }
}
extension Date: XMLRPCRawValueRepresentable {
    public static var xmlRpcKind: XMLRPCValueKind { return .DateTime }
    public var xmlRpcRawValue: String {
        return self.iso8601String
    }
    public init?(xmlRpcRawValue: String) {
        guard let date = iso8601DateFormatter.date(from: xmlRpcRawValue) else {
            return nil
        }
        self = date
    }
}

// MARK: Data
extension Data: XMLRPCRawValueRepresentable {
    public static var xmlRpcKind: XMLRPCValueKind { return .Base64 }
    public var xmlRpcRawValue: String {
        return self.base64EncodedString(options: [])
    }
    public init?(xmlRpcRawValue: String) {
        guard let data = Data(base64Encoded: xmlRpcRawValue, options: .ignoreUnknownCharacters) else {
            return nil
        }
        self = data
    }
}
