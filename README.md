
# AlamofireXMLRPC #

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%26%20OSX-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift%204-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/kodlian/AlamofireXMLRPC.svg?style=flat
                        )](https://github.com/kodlian/AlamofireXMLRPC/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/AlamofireXMLRPC.svg?style=flat)](http://cocoadocs.org/docsets/AlamofireXMLRPC/)
[![Build Status](https://travis-ci.org/kodlian/AlamofireXMLRPC.svg?branch=master)](https://travis-ci.org/kodlian/AlamofireXMLRPC)
[![codecov](https://codecov.io/gh/kodlian/AlamofireXMLRPC/branch/master/graph/badge.svg)](https://codecov.io/gh/kodlian/AlamofireXMLRPC)
[![codebeat badge](https://codebeat.co/badges/8021faba-a806-48ac-96bb-5b5ef95a542c)](https://codebeat.co/projects/github-com-kodlian-alamofirexmlrpc)


AlamofireXMLRPC brings [XML RPC](http://xmlrpc.scripting.com/) functionalities to [Alamofire](https://github.com/Alamofire/Alamofire). It aims to provide an easy way to perform XMLRPC call and to retrieve smoothly the response.

XML is handled internally with [AEXML](https://github.com/tadija/AEXML).

## Example
Take the following request and response handler:

```swift
let data: NSData = ...
let params: [Any] = [42, "text", 3.44, Date(), data]
AlamofireXMLRPC.request("http://localhost:8888/xmlrpc", methodName: "foo", parameters: params).responseXMLRPC { (response: DataResponse<XMLRPCNode>) -> Void in
	   switch response.result {
      case .success(let value):
      		if let message = value[0].string, age = value[1]["age"].int32  {
              ...
     		}
      case .failure:
            ...
      }

```

It will generate the following call and lets you parse the corresponding answer from the XMLRPC service:

```xml
<!-- request -->
<methodCall>
	<methodName>foo</methodName>
	<params>
		<param>
			<value>
				<int>42</int>
			</value>
		</param>
		<param>
			<value>
				<string>text</string>
			</value>
		</param>
		<param>
			<value>
				<double>3.44</double>
			</value>
		</param>
		<param>
			<value>
				<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>
			</value>
		</param>
		<param>
			<value>
				<base64>eW91IGNhbid0IHJlYWQgdGhpcyE=</base64>
			</value>
		</param>
	</params>
</methodCall>

<!-- response -->
<methodResponse>
  <params>
    <param>
      <value>
        <string>Hello world!</string>
      </value>
    </param>
    <param>
      <value>
        <struct>
          <member>
            <name>name</name>
            <value>
              <string>John Doe</string>
            </value>
          </member>
          <member>
            <name>age</name>
            <value>
              <int>36</int>
            </value>
          </member>
        </struct>
      </value>
    </param>
  </params>
</methodResponse>
```

## Requirements
 - iOS 9.0+ / Mac OS X 10.11+
 - Xcode 9

## Install CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `AlamofireXMLRPC`by adding it to your `Podfile`:
```ruby
use_frameworks!

target 'MyApp' do
	pod 'AlamofireXMLRPC', :git => 'https://github.com/kodlian/AlamofireXMLRPC.git'
end
```


## Request
### Method request
```swift
// Call XMLRPC service with the sharedManager of Alamofire
AlamofireXMLRPC.request("https://xmlrpcservice", method:"foo" parameters: [1,2.0,"ddd",["key":"value"]])
// Call XMLRPC service with your custom manager
manager.requestXMLRPC("https://xmlrpcservice", method:"foo" parameters: [1,2.0,"ddd",["key":"value"]])
```

### XMLRPC Request convertible
Types adopting the ```XMLRPCRequestConvertible``` protocol can be used to construct XMLRPC call.

```swift
public protocol XMLRPCRequestConvertible {
    var url: URLConvertible { get }
    var methodName: String { get }
    var parameters: [Any]? { get }
    var headers: [String : String]? { get }
}

struct MyRequest: XMLRPCRequestConvertible {
  ...
}

let request =  MyRequest(...)
Alamofire.request(request) // Call XMLRPC service with Alamofire
```

### Values
#### Mapping
AlamofireXMLRPC uses the following mapping for swift values to XML RPC values:

| Swift   					| Example	| XMLRPC  							| note 								|
|:---------------------------------------------:|:-------------:|:-------------------------------------------------------------:|:-------------------------------------------------------------:|
| String        				| "foo"         | ```<string>foo</string>``` 					| 								|
| Int, Int32, Int16, Int8, UInt16, UInt8 	| 42   		| ```<int>42</int>``` 						| XML RPC Integer is 32bits, Int values are converted to Int32 	|
| Bool 						| true  	| ```<boolean>1</boolean>``` 					| 								|
| Double, Float 				| 3.44      	| ```<double>3.44</double>```					| 								|
| Date 					| Date() 	| ```<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>``` 	| 								|
| Data 					| Data()  	| ```<base64>eW91IGNhbid0IHJlYWQgdGhpcyE=</base64>``` 		| 								|

By default other types will be mapped as XML RPC String and use the default String representation. Bu you can provide your own mapping for custom Types by adopting the protocol ```XMLRPCRawValueRepresentable```.

``` swift
enum XMLRPCValueKind: String {
    case integer = "int"
    case double = "double"
    case boolean = "boolean"
    case string = "string"
    case dateTime = "dateTime.iso8601"
    case base64 = "base64"
}

protocol XMLRPCRawValueRepresentable {
    static var xmlrpcKind: XMLRPCValueKind { get }
    var xmlrpcRawValue: String { get }
    init?(xmlrpcRawValue: String)
}
```

#### Collection
Swift arrays ```[Any]``` are convertible to XMLRPC arrays.

```swift
[1,"too"]
```

As well dictionaries ```[String:Any]``` are convertible to XMLRPC structure.

```swift
["name":"John Doe","age":35]
```


## Response
### Response
XMLRPC Responses are handled with the method ```responseXMLRPC(completionHandler: DataResponse<XMLRPCNode> -> Void)```. The response's XMLRPC parameters are mapped to an ```XMLRPCNode```. This allows you to fetch easily data within complex structure or tree.

#### Subscript
For each XMLRPCNode you can access subnode by index or by String key. Internally children of XMLRPC Array and Structure will be fetched.

```swift
aRequest.responseXMLRPC{ (response: DataResponse<XMLRPCNode>) -> Void in
      switch response.result {
      case .success(let value):
      		if let message = value[0]["aKey"][9].string  {
              ...
     		}
      case .failure:
            ...
      }
}
```

Don't worry about unwrapping things and checking the value type or presence. The optional management is solely done when you request the swift value with one of the optional getters.

For instance, you can call ```value[0]["aKey"][9]``` without worrying if the objects tree actually exists.

#### Optional getters

```swift
var array: [XMLRPCNode]?
var dictionary: [String:XMLRPCNode]?
var string: String?
var int32: Int32?
var double: Double?
var bool: Bool?
var date: Date?
var data: Data?
var count: Int?
```

## License
AlamofireXMLRPC is released under the MIT license. See [LICENSE](LICENSE) for details.
