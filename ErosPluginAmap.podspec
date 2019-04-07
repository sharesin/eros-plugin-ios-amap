#
# Be sure to run `pod lib lint ErosPluginAmap.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ErosPluginAmap'
  s.version          = '0.1.0'
  s.summary          = 'ErosPluginAmap Source .'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  ErosPluginAmap Source .
  DESC
  
  s.homepage         = 'https://github.com/sharesin/eros-plugin-ios-amap'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sharesin' => 'zhujigao@caas.com' }
  s.source           = { :git => 'https://github.com/sharesin/eros-plugin-ios-amap.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '8.0'
  
  s.source_files = 'ErosPluginAmap/Classes/**/*'
  s.resources = 'ErosPluginAmap/Assets/*'
  
  # s.resource_bundles = {
  #   'ErosPluginAmap' => ['ErosPluginAmap/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.requires_arc = true
  
  s.dependency 'AMap3DMap-NO-IDFA'
  s.dependency 'AMapSearch-NO-IDFA'
  s.dependency 'AMapLocation-NO-IDFA'
  s.dependency 'WeexPluginLoader'
  s.dependency 'WeexSDK'
  s.dependency 'SDWebImage', '3.7.6'
end
