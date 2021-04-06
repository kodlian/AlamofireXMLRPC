Pod::Spec.new do |s|
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name = "AlamofireXMLRPC"
  s.version = "2.2.0"
  s.summary = "AlamofireXMLRPC brings XMLRPC functionalities to Alamofire."
  s.description = "AlamofireXMLRPC brings XMLRPC functionalities to Alamofire. It aims to provide an easy way to perform XMLRPC call and to retrieve smoothly the response."
  s.homepage = "https://github.com/kodlian/AlamofireXMLRPC"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author = "Jérémy Marchand"
  s.social_media_url = "http://twitter.com/kodlian"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #  When using multiple platforms
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source = { :git => "https://github.com/kodlian/AlamofireXMLRPC.git", :tag => s.version }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Sources/AlamofireXMLRPC/*.swift"

  #  Dependency
  s.dependency 'AEXML', '~> 4.6.0'
  s.dependency 'Alamofire', '~> 5.4.2'
end
