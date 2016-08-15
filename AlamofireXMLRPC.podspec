Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AlamofireXMLRPC"
  s.version      = "2.0.0"
  s.summary      = "AlamofireXMLRPC aims to provide an easy way to perform call on XML RPC service and allows to retrieve smoothly the response"
  s.homepage     = "https://github.com/kodlian/AlamofireXMLRPC"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = "Jérémy Marchand"
  s.social_media_url   = "http://twitter.com/kodlian"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #  When using multiple platforms
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/kodlian/AlamofireXMLRPC.git", :tag => "1.0.0" }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "AlamofireXMLRPC/*.swift"

  #  Dependency
  s.dependency 'Alamofire'
  s.dependency 'AEXML'

end
