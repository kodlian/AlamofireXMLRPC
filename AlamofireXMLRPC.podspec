Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AlamofireXMLRPC"
  s.version      = "2.2.0"
  s.summary      = "AlamofireXMLRPC brings XMLRPC functionalities to Alamofire."
  s.description  = "AlamofireXMLRPC brings XMLRPC functionalities to Alamofire. It aims to provide an easy way to perform XMLRPC call and to retrieve smoothly the response."
  s.homepage     = "https://github.com/kodlian/AlamofireXMLRPC"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = "Jérémy Marchand"
  s.social_media_url   = "http://twitter.com/kodlian"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #  When using multiple platforms
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/kodlian/AlamofireXMLRPC.git", :tag => "2.2.0" }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Sources/*.swift"

  #  Dependency
  s.dependency 'Alamofire'
  s.dependency 'AEXML'

end
