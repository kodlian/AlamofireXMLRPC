use_frameworks!

target 'AlamofireXMLRPC' do
  pod 'AEXML', '~> 4.6.0'
  pod 'Alamofire', '~> 5.4.2'
  pod 'SwiftLint'

  target 'AlamofireXMLRPCTests' do
  end
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
